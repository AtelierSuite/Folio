import AppIntents
import Foundation
import Planner
import UniformTypeIdentifiers

/// Folio has no pinned notes and creates notes at the top of the notes folder, so `isPinned` and
/// `folder` are accepted but not used.
@available(iOS 27.0, macOS 27.0, *)
@AppIntent(schema: .notes.createNote)
struct CreateNoteSchemaIntent {
    static let isAssistantOnly = true

    var name: String
    var content: AttributedString?
    var folder: NoteFolderSchemaEntity?
    var isPinned: Bool
    var attachments: [IntentFile]

    @Dependency private var library: NotesLibrary

    @MainActor
    func perform() async throws -> some ReturnsValue<NoteSchemaEntity> {
        let actions = NoteIntentActions(library: library)
        let text = content.map { String($0.characters) } ?? ""
        var note = try await actions.createNote(titled: name, text: text)
        note = try await actions.attach(attachments.map(NoteAttachment.init), to: note)
        return .result(value: NoteSchemaEntity(note))
    }
}

extension NoteAttachment {
    init(_ file: IntentFile) {
        self.init(data: file.data, fileName: file.filename, type: file.type)
    }
}
