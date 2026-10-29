import CoreSpotlight
import Planner
import SwiftUI

extension View {
    func opensNotesFromSpotlight(library: NotesLibrary, navigator: NoteNavigator) -> some View {
        onContinueUserActivity(CSSearchableItemActionType) { activity in
            guard let identifier = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String else {
                return
            }
            Task {
                await library.start()
                if let url = library.noteURL(forEntityIdentifier: identifier) {
                    navigator.openNote(at: url)
                }
            }
        }
    }
}
