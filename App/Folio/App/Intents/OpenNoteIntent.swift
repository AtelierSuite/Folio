import AppIntents
import Planner

struct OpenNoteIntent: OpenIntent {
    static let title = LocalizedStringResource("OpenNoteIntent.Title", table: "Spotlight")

    @Parameter(title: LocalizedStringResource("OpenNoteIntent.Note", table: "Spotlight"))
    var target: NoteEntity

    @Dependency private var navigator: NoteNavigator

    @MainActor
    func perform() async throws -> some IntentResult {
        navigator.openNote(at: target.url)
        return .result()
    }
}
