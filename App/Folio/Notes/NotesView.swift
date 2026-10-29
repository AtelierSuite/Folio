import SwiftUI

struct NotesView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                String(localized: "Placeholder.Title", table: "Notes"),
                systemImage: "note.text",
                description: Text(String(localized: "Placeholder.Description", table: "Notes"))
            )
            .navigationTitle(String(localized: "Title", table: "Notes"))
        }
    }
}
