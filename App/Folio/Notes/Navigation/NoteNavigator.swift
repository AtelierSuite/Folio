import Foundation
import Observation

/// Lets anything outside the Notes tab, such as Spotlight or App Intents, open a note.
@Observable
final class NoteNavigator {
    var requestedNoteURL: URL?

    func openNote(at url: URL) {
        requestedNoteURL = url
    }
}
