import Foundation
import Observation

@MainActor
@Observable
public final class NoteEditingSession {
    public enum State: Equatable {
        case loading
        case ready
        case failed(String)
    }

    public private(set) var url: URL
    public let focusesEditorOnOpen: Bool
    public private(set) var state = State.loading
    public private(set) var savedNote: Note?
    public private(set) var saveFailureMessage: String?
    public var conflictedCopyURL: URL?
    public var text = "" {
        didSet {
            if text != oldValue {
                scheduleSave()
            }
        }
    }

    @ObservationIgnored private let library: NotesLibrary
    @ObservationIgnored private let saveDelay: Duration
    @ObservationIgnored private var saveTask: Task<Void, Never>?
    @ObservationIgnored private var latestSave: Task<Void, Never>?
    @ObservationIgnored private var saveGeneration = 0
    @ObservationIgnored private var isClosed = false
    @ObservationIgnored private var failedSaveAttempts = 0

    public init(
        url: URL, library: NotesLibrary, focusesEditorOnOpen: Bool = false, saveDelay: Duration = .seconds(1)
    ) {
        self.url = url
        self.focusesEditorOnOpen = focusesEditorOnOpen
        self.library = library
        self.saveDelay = saveDelay
    }

    public var title: String {
        url.deletingPathExtension().lastPathComponent
    }

    public var hasUnsavedChanges: Bool {
        savedNote.map { $0.text != text } ?? false
    }

    public func load() async {
        state = .loading
        do {
            apply(try await library.read(url))
            state = .ready
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    @discardableResult
    public func flush() async -> Bool {
        saveTask?.cancel()
        saveTask = nil
        await enqueueSave().value
        return !hasUnsavedChanges
    }

    public func retrySave() {
        Task {
            await flush()
        }
    }

    public func didMove(to newURL: URL) {
        url = newURL
        if let savedNote {
            self.savedNote = Note(url: newURL, modifiedDate: savedNote.modifiedDate, text: savedNote.text)
        }
    }

    public func close() {
        isClosed = true
        saveTask?.cancel()
    }

    public func reloadIfChangedElsewhere(in files: [NoteFile]) {
        guard state == .ready, !hasUnsavedChanges, saveTask == nil, latestSave == nil,
              let savedNote,
              let file = files.first(where: { $0.url == url }),
              file.modifiedDate.timeIntervalSince(savedNote.modifiedDate) > 1 else {
            return
        }
        Task {
            if let note = try? await library.read(url), !hasUnsavedChanges {
                apply(note)
            }
        }
    }

    private func scheduleSave(after delay: Duration? = nil) {
        guard state == .ready, !isClosed else {
            return
        }
        saveTask?.cancel()
        saveTask = Task { [weak self, delay = delay ?? saveDelay] in
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled, let self else {
                return
            }
            saveTask = nil
            await enqueueSave().value
        }
    }

    /// Each save waits for the one before it, so it starts from the note that save left on disk.
    private func enqueueSave() -> Task<Void, Never> {
        saveGeneration += 1
        let generation = saveGeneration
        let previousSave = latestSave
        let task = Task { [weak self] in
            await previousSave?.value
            await self?.save()
            if self?.saveGeneration == generation {
                self?.latestSave = nil
            }
        }
        latestSave = task
        return task
    }

    private func save() async {
        guard !isClosed, let savedNote, hasUnsavedChanges else {
            return
        }
        do {
            switch try await library.save(text, over: savedNote) {
            case .saved(let note):
                self.savedNote = note
            case .conflict(let current, let copyURL):
                apply(current)
                conflictedCopyURL = copyURL
            }
            failedSaveAttempts = 0
            saveFailureMessage = nil
        } catch {
            failedSaveAttempts += 1
            saveFailureMessage = error.localizedDescription
            scheduleSave(after: retryDelay)
        }
    }

    private var retryDelay: Duration {
        .seconds(min(60, 1 << min(failedSaveAttempts, 6)))
    }

    private func apply(_ note: Note) {
        savedNote = note
        if text != note.text {
            text = note.text
        }
    }
}
