import AppIntents
import Planner

@available(iOS 27.0, macOS 27.0, *)
struct NoteSchemaEntityQuery: EntityStringQuery {
    @Dependency private var library: NotesLibrary

    func entities(for identifiers: [NoteSchemaEntity.ID]) async throws -> [NoteSchemaEntity] {
        await library.noteEntities(for: identifiers).map(NoteSchemaEntity.init)
    }

    func entities(matching string: String) async throws -> [NoteSchemaEntity] {
        let identifiers = await library.noteEntities(matching: string).map(\.id)
        return await library.noteEntities(for: identifiers).map(NoteSchemaEntity.init)
    }

    func suggestedEntities() async throws -> [NoteSchemaEntity] {
        await library.suggestedNoteEntities().map(NoteSchemaEntity.init)
    }
}
