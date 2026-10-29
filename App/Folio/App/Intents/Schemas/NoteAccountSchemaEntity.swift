import AppIntents
import Foundation

/// Folio keeps all notes in one folder, so there's a single account.
@available(iOS 27.0, macOS 27.0, *)
@AppEntity(schema: .notes.account)
struct NoteAccountSchemaEntity {
    static let defaultQuery = NoteAccountSchemaEntityQuery()
    static let folio = NoteAccountSchemaEntity()

    let id: String
    var name: String

    private init() {
        id = "folio"
        name = "Folio"
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

@available(iOS 27.0, macOS 27.0, *)
struct NoteAccountSchemaEntityQuery: EntityQuery {
    func entities(for identifiers: [NoteAccountSchemaEntity.ID]) async throws -> [NoteAccountSchemaEntity] {
        identifiers.contains(NoteAccountSchemaEntity.folio.id) ? [.folio] : []
    }

    func suggestedEntities() async throws -> [NoteAccountSchemaEntity] {
        [.folio]
    }
}
