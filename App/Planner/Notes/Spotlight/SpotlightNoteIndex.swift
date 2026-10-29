import AppIntents
import CoreSpotlight

public struct SpotlightNoteIndex: NoteSearchIndexing {
    public init() {}

    public func index(_ entities: [NoteEntity]) async throws {
        try await CSSearchableIndex.default().indexAppEntities(entities)
    }

    public func deleteNotes(identifiedBy identifiers: [NoteEntity.ID]) async throws {
        try await CSSearchableIndex.default().deleteAppEntities(identifiedBy: identifiers, ofType: NoteEntity.self)
    }

    public func deleteAllNotes() async throws {
        try await CSSearchableIndex.default().deleteAppEntities(ofType: NoteEntity.self)
    }
}
