import Planner
import SwiftUI

extension View {
    func opensNoteDeepLinks(library: NotesLibrary, navigator: NoteNavigator) -> some View {
        onOpenURL { url in
            guard NoteDeepLink.relativePath(from: url) != nil else {
                return
            }
            Task {
                await library.start()
                if let noteURL = library.noteURL(forDeepLink: url) {
                    navigator.openNote(at: noteURL)
                }
            }
        }
    }
}
