import AppIntents
import Planner

/// Renames a note or replaces its text; the front matter linking it to events and days is kept.
struct EditNoteIntent: AppIntent {
    static let title = LocalizedStringResource("EditNoteIntent.Title", table: "AppIntents")
    static let description = IntentDescription(
        LocalizedStringResource("EditNoteIntent.Description", table: "AppIntents")
    )

    @Parameter(title: LocalizedStringResource("EditNoteIntent.Note", table: "AppIntents"))
    var note: NoteEntity

    @Parameter(title: LocalizedStringResource("EditNoteIntent.NewTitle", table: "AppIntents"))
    var newTitle: String?

    @Parameter(
        title: LocalizedStringResource("EditNoteIntent.NewText", table: "AppIntents"),
        inputOptions: String.IntentInputOptions(multiline: true)
    )
    var newText: String?

    @Dependency private var library: NotesLibrary

    static var parameterSummary: some ParameterSummary {
        Summary("Edit \(\.$note)", table: "AppIntents") {
            \.$newTitle
            \.$newText
        }
    }

    init() {}

    init(note: NoteEntity) {
        self.note = note
    }

    @MainActor
    func perform() async throws -> some ReturnsValue<NoteEntity> & ProvidesDialog {
        let edited = try await NoteIntentActions(library: library).edit(note, newTitle: newTitle, newText: newText)
        let dialog = String(localized: "Dialog.NoteUpdated \(edited.title)", table: "AppIntents")
        return .result(value: edited, dialog: IntentDialog(stringLiteral: dialog))
    }
}
