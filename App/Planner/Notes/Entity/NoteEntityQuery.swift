import AppIntents
import Foundation

public struct NoteEntityQuery: EntityStringQuery {
    @Dependency private var library: NotesLibrary

    public init() {}

    public func entities(for identifiers: [NoteEntity.ID]) async throws -> [NoteEntity] {
        await library.noteEntities(for: identifiers)
    }

    public func entities(matching string: String) async throws -> [NoteEntity] {
        await library.noteEntities(matching: string)
    }

    public func suggestedEntities() async throws -> [NoteEntity] {
        await library.suggestedNoteEntities()
    }
}
