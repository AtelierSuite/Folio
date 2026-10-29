import AppIntents
import Planner

/// Adds a line to today's daily note, creating the note first if there isn't one yet.
struct AppendToDailyNoteIntent: AppIntent {
    static let title = LocalizedStringResource("AppendToDailyNoteIntent.Title", table: "AppIntents")
    static let description = IntentDescription(
        LocalizedStringResource("AppendToDailyNoteIntent.Description", table: "AppIntents")
    )

    @Parameter(
        title: LocalizedStringResource("AppendToDailyNoteIntent.Text", table: "AppIntents"),
        inputOptions: String.IntentInputOptions(multiline: true)
    )
    var text: String

    @Dependency private var library: NotesLibrary

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$text) to today's note", table: "AppIntents")
    }

    @MainActor
    func perform() async throws -> some ReturnsValue<NoteEntity> & ProvidesDialog {
        let note = try await NoteIntentActions(library: library).appendToDailyNote(text)
        let dialog = String(localized: "Dialog.DailyNoteAppended", table: "AppIntents")
        return .result(value: note, dialog: IntentDialog(stringLiteral: dialog))
    }
}
