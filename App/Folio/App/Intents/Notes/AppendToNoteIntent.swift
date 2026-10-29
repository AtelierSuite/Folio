import AppIntents
import Planner

struct AppendToNoteIntent: AppIntent {
    static let title = LocalizedStringResource("AppendToNoteIntent.Title", table: "AppIntents")
    static let description = IntentDescription(
        LocalizedStringResource("AppendToNoteIntent.Description", table: "AppIntents")
    )

    @Parameter(title: LocalizedStringResource("AppendToNoteIntent.Note", table: "AppIntents"))
    var note: NoteEntity

    @Parameter(
        title: LocalizedStringResource("AppendToNoteIntent.Text", table: "AppIntents"),
        inputOptions: String.IntentInputOptions(multiline: true)
    )
    var text: String

    @Dependency private var library: NotesLibrary

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$text) to \(\.$note)", table: "AppIntents")
    }

    init() {}

    init(note: NoteEntity) {
        self.note = note
    }

    @MainActor
    func perform() async throws -> some ReturnsValue<NoteEntity> & ProvidesDialog {
        let updated = try await NoteIntentActions(library: library).append(text, to: note)
        let dialog = String(localized: "Dialog.NoteAppended \(updated.title)", table: "AppIntents")
        return .result(value: updated, dialog: IntentDialog(stringLiteral: dialog))
    }
}
