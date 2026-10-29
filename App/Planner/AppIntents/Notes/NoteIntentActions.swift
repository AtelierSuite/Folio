import Foundation

/// What the note intents do, against the app's `NotesLibrary`.
@MainActor
public struct NoteIntentActions {
    private let library: NotesLibrary

    public init(library: NotesLibrary) {
        self.library = library
    }

    public func createNote(titled title: String, text: String = "") async throws -> NoteEntity {
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { throw PlannerIntentError.emptyTitle }
        await library.start()
        let note = try await Self.rewording { try await library.createNote(titled: title, text: text) }
        return try entity(for: note)
    }

    public func append(_ text: String, to entity: NoteEntity) async throws -> NoteEntity {
        let url = try await url(for: entity)
        return try await update(url) { NoteTextAppending.appending(text, to: $0) }
    }

    public func attach(_ attachments: [NoteAttachment], to entity: NoteEntity) async throws -> NoteEntity {
        let url = try await url(for: entity)
        guard !attachments.isEmpty else { return entity }
        var links: [String] = []
        for attachment in attachments {
            let path = try await Self.rewording {
                try await library.addAsset(attachment.data, named: attachment.fileName, for: url)
            }
            links.append(attachment.markdownLink(to: path))
        }
        return try await update(url) { NoteTextAppending.appending(links.joined(separator: "\n"), to: $0) }
    }

    /// Creates the day's note first if there isn't one yet.
    public func appendToDailyNote(_ text: String, on date: Date = .now) async throws -> NoteEntity {
        await library.start()
        let url = try await Self.rewording { try await library.createDailyNote(on: date) }
        return try await update(url) { NoteTextAppending.appending(text, to: $0) }
    }

    public func edit(_ entity: NoteEntity, newTitle: String?, newText: String?) async throws -> NoteEntity {
        var url = try await url(for: entity)
        if let newText {
            url = try await update(url) { NoteTextAppending.replacingBody(of: $0, with: newText) }.url
        }
        if let newTitle = newTitle?.trimmingCharacters(in: .whitespacesAndNewlines), !newTitle.isEmpty {
            url = try await Self.rewording { try await library.rename(url, to: newTitle) }
        }
        return try self.entity(for: try await Self.rewording { try await library.read(url) })
    }

    public func moveToTrash(_ entity: NoteEntity) async throws {
        let url = try await url(for: entity)
        try await Self.rewording { try await library.moveToTrash(url) }
    }

    public func url(for entity: NoteEntity) async throws -> URL {
        await library.start()
        guard library.store != nil else { throw PlannerIntentError.notesUnavailable }
        guard let url = library.noteURL(forEntityIdentifier: entity.id) else { throw PlannerIntentError.noteNotFound }
        return url
    }

    private func update(_ url: URL, _ transform: (String) -> String) async throws -> NoteEntity {
        let note = try await Self.rewording { try await library.read(url) }
        let result = try await Self.rewording { try await library.save(transform(note.text), over: note) }
        switch result {
        case .saved(let saved):
            return try entity(for: saved)
        case .conflict(let current, _):
            return try entity(for: current)
        }
    }

    private func entity(for note: Note) throws -> NoteEntity {
        guard let relativePath = library.store?.relativePath(of: note.url) else {
            throw PlannerIntentError.notesUnavailable
        }
        return NoteEntity(note: note, relativePath: relativePath)
    }

    private static func rewording<Value>(_ operation: () async throws -> Value) async throws -> Value {
        do {
            return try await operation()
        } catch let error as NotesStorageError {
            throw error == .invalidTitle ? PlannerIntentError.emptyTitle : PlannerIntentError.notesUnavailable
        } catch CocoaError.fileReadNoSuchFile, CocoaError.fileNoSuchFile {
            throw PlannerIntentError.noteNotFound
        }
    }
}
