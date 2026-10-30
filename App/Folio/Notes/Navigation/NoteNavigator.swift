import Foundation
import Observation

/// Lets app-wide callers without a scene, such as App Intents, open a note.
/// `RootView` forwards it to the scene's `AppRouter`.
@Observable
final class NoteNavigator {
    var requestedNoteURL: URL?

    func openNote(at url: URL) {
        requestedNoteURL = url
    }
}
