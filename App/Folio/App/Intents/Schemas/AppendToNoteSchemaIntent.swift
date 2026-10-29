import AppIntents
import Foundation
import Planner
import UniformTypeIdentifiers

@available(iOS 27.0, macOS 27.0, *)
@AppIntent(schema: .notes.appendText)
struct AppendToNoteSchemaIntent {
    static let isAssistantOnly = true

    var target: NoteSchemaEntity
    var content: AttributedString

    @Dependency private var library: NotesLibrary

    @MainActor
    func perform() async throws -> some ReturnsValue<NoteSchemaEntity> {
        let note = try await NoteIntentActions(library: library)
            .append(String(content.characters), to: target.noteEntity)
        return .result(value: NoteSchemaEntity(note))
    }
}
