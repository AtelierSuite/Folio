import Foundation
@testable import Planner

actor FakeNoteSearchIndex: NoteSearchIndexing {
    enum Operation: Equatable {
        case index([NoteEntity.ID])
        case delete([NoteEntity.ID])
        case deleteAll
    }

    private(set) var operations: [Operation] = []
    private(set) var entities: [NoteEntity.ID: NoteEntity] = [:]

    func index(_ entities: [NoteEntity]) async throws {
        operations.append(.index(entities.map(\.id)))
        entities.forEach { self.entities[$0.id] = $0 }
    }

    func deleteNotes(identifiedBy identifiers: [NoteEntity.ID]) async throws {
        operations.append(.delete(identifiers))
        identifiers.forEach { entities[$0] = nil }
    }

    func deleteAllNotes() async throws {
        operations.append(.deleteAll)
        entities.removeAll()
    }

    func clearOperations() {
        operations.removeAll()
    }
}
