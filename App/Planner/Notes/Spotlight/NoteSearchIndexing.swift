import Foundation

public protocol NoteSearchIndexing: Sendable {
    func index(_ entities: [NoteEntity]) async throws
    func deleteNotes(identifiedBy identifiers: [NoteEntity.ID]) async throws
    func deleteAllNotes() async throws
}
