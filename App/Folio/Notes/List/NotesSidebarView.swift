import Planner
import SwiftUI

struct NotesSidebarView: View {
    @Environment(NotesLibrary.self) private var library
    @Binding var selection: NotesSidebarItem?
    let onCreate: () -> Void
    let onRename: (URL) -> Void
    let onTrash: (URL) -> Void

    var body: some View {
        content
            .navigationTitle(String(localized: "Title", table: "Notes"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(
                        String(localized: "List.NewNote", table: "Notes"),
                        systemImage: "square.and.pencil",
                        action: onCreate
                    )
                        .disabled(library.store == nil)
                        .keyboardShortcut("n", modifiers: [.command])
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch library.status {
        case .loading:
            ProgressView()
        case .iCloudUnavailable, .folderUnavailable:
            NotesUnavailableView(status: library.status)
        case .ready:
            NotesListView(selection: $selection, onRename: onRename, onTrash: onTrash)
        }
    }
}
