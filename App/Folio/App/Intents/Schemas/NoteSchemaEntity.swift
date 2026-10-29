import AppIntents
import Foundation
import Planner

/// The note as Apple Intelligence's notes schema sees it. It shares `NoteEntity`'s identifiers; Folio
/// keeps `NoteEntity` for Spotlight, Shortcuts and older systems, which can't use the schema.
@available(iOS 27.0, macOS 27.0, *)
@AppEntity(schema: .notes.note)
struct NoteSchemaEntity {
    static let defaultQuery = NoteSchemaEntityQuery()

    let id: String
    var name: AttributedString
    var content: AttributedString?
    var folder: NoteFolderSchemaEntity?
    var isPinned: Bool
    var creationDate: Date?
    var modificationDate: Date?
    var attachments: [IntentFile]

    init(_ note: NoteEntity) {
        id = note.id
        name = AttributedString(note.title)
        content = note.plainText.isEmpty ? nil : AttributedString(note.plainText)
        folder = NoteFolderSchemaEntity(containing: note.id)
        isPinned = false
        creationDate = note.date
        modificationDate = note.modifiedDate
        attachments = []
    }

    var noteEntity: NoteEntity {
        NoteEntity(id: id, url: URL(filePath: id), title: String(name.characters), modifiedDate: .now)
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(String(name.characters))",
            image: DisplayRepresentation.Image(systemName: "note.text")
        )
    }
}
