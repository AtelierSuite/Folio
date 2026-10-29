import AppIntents
import Planner

struct CreateNoteIntent: AppIntent {
    static let title = LocalizedStringResource("CreateNoteIntent.Title", table: "AppIntents")
    static let description = IntentDescription(
        LocalizedStringResource("CreateNoteIntent.Description", table: "AppIntents")
    )

    @Parameter(title: LocalizedStringResource("CreateNoteIntent.NoteTitle", table: "AppIntents"))
    var noteTitle: String

    @Parameter(
        title: LocalizedStringResource("CreateNoteIntent.Text", table: "AppIntents"),
        inputOptions: String.IntentInputOptions(multiline: true)
    )
    var text: String?

    @Dependency private var library: NotesLibrary

    static var parameterSummary: some ParameterSummary {
        Summary("Create a note called \(\.$noteTitle)", table: "AppIntents") {
            \.$text
        }
    }

    @MainActor
    func perform() async throws -> some ReturnsValue<NoteEntity> & ProvidesDialog {
        let note = try await NoteIntentActions(library: library).createNote(titled: noteTitle, text: text ?? "")
        let dialog = String(localized: "Dialog.NoteCreated \(note.title)", table: "AppIntents")
        return .result(value: note, dialog: IntentDialog(stringLiteral: dialog))
    }
}
