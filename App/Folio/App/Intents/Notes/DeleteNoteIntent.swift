import AppIntents
import Planner

/// Moves a note to Folio's trash after asking, so it can still be restored.
struct DeleteNoteIntent: AppIntent {
    static let title = LocalizedStringResource("DeleteNoteIntent.Title", table: "AppIntents")
    static let description = IntentDescription(
        LocalizedStringResource("DeleteNoteIntent.Description", table: "AppIntents")
    )

    @Parameter(title: LocalizedStringResource("DeleteNoteIntent.Note", table: "AppIntents"))
    var note: NoteEntity

    @Dependency private var library: NotesLibrary

    static var parameterSummary: some ParameterSummary {
        Summary("Delete \(\.$note)", table: "AppIntents")
    }

    init() {}

    init(note: NoteEntity) {
        self.note = note
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let actions = NoteIntentActions(library: library)
        _ = try await actions.url(for: note)
        try await requestConfirmation(
            actionName: .custom(
                acceptLabel: LocalizedStringResource("Confirmation.Delete", table: "AppIntents"),
                acceptAlternatives: [],
                denyLabel: LocalizedStringResource("Confirmation.Cancel", table: "AppIntents"),
                denyAlternatives: [],
                destructive: true
            ),
            dialog: IntentDialog(stringLiteral: String(
                localized: "Dialog.ConfirmNoteDeletion \(note.title)", table: "AppIntents"
            ))
        )
        try await actions.moveToTrash(note)
        let dialog = String(localized: "Dialog.NoteDeleted \(note.title)", table: "AppIntents")
        return .result(dialog: IntentDialog(stringLiteral: dialog))
    }
}
