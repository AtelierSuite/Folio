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
    public var conflictedCopyURL: URL?
    public var text = "" {
        didSet {
            if text != oldValue {
                scheduleSave()
            }
        }
    }

    @ObservationIgnored private let library: NotesLibrary
    @ObservationIgnored private var saveTask: Task<Void, Never>?
    @ObservationIgnored private var isClosed = false

    public init(url: URL, library: NotesLibrary, focusesEditorOnOpen: Bool = false) {
        self.url = url
        self.focusesEditorOnOpen = focusesEditorOnOpen
        self.library = library
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

    public func flush() async {
        saveTask?.cancel()
        saveTask = nil
        await save()
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
        guard state == .ready, !hasUnsavedChanges, saveTask == nil,
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

    private func scheduleSave() {
        guard state == .ready, !isClosed else {
            return
        }
        saveTask?.cancel()
        saveTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else {
                return
            }
            await self?.save()
            self?.saveTask = nil
        }
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
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    private func apply(_ note: Note) {
        savedNote = note
        if text != note.text {
            text = note.text
        }
    }
}
