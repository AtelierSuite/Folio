import AppIntents
import Foundation
import Planner
import UniformTypeIdentifiers

/// Renames the note, replaces its text and adds attachments; `folder` and `isPinned` aren't used.
@available(iOS 27.0, macOS 27.0, *)
@AppIntent(schema: .notes.updateNote)
struct UpdateNoteSchemaIntent {
    static let isAssistantOnly = true

    var target: NoteSchemaEntity
    var name: String?
    var content: AttributedString?
    var folder: NoteFolderSchemaEntity?
    var isPinned: Bool?
    var attachments: [IntentFile]?

    @Dependency private var library: NotesLibrary

    @MainActor
    func perform() async throws -> some ReturnsValue<NoteSchemaEntity> {
        let actions = NoteIntentActions(library: library)
        var note = try await actions.edit(
            target.noteEntity, newTitle: name, newText: content.map { String($0.characters) }
        )
        note = try await actions.attach((attachments ?? []).map(NoteAttachment.init), to: note)
        return .result(value: NoteSchemaEntity(note))
    }
}
