import Planner
import SwiftUI

extension View {
    /// An open window takes the link instead of a new one being created for it, which macOS does by default.
    func opensNoteDeepLinks(library: NotesLibrary, navigator: NoteNavigator) -> some View {
        handlesExternalEvents(preferring: [NoteDeepLink.prefix], allowing: ["*"])
            .onOpenURL { url in
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
