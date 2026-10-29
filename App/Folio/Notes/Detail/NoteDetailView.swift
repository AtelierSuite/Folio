import Planner
import SwiftUI

struct NoteDetailView: View {
    let session: NoteEditingSession?
    let onRename: (URL) -> Void
    let onTrash: (URL) -> Void

    var body: some View {
        if let session {
            NoteSessionView(session: session, onRename: onRename, onTrash: onTrash)
                .id(session.url)
        } else {
            ContentUnavailableView(
                String(localized: "Detail.NoSelection.Title", table: "Notes"),
                systemImage: "note.text",
                description: Text(String(localized: "Detail.NoSelection.Description", table: "Notes"))
            )
        }
    }
}
