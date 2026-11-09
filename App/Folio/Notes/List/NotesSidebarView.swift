import Planner
import SwiftUI

struct NotesSidebarView: View {
    @Environment(NotesLibrary.self) private var library
    @AppStorage(NoteSortOrder.storageKey) private var sortOrder: NoteSortOrder = .dateModified
    @Binding var selection: NotesSidebarItem?
    let onCreate: () -> Void
    let onRename: (URL) -> Void
    let onTrash: (URL) -> Void

    var body: some View {
        content
            .navigationTitle(String(localized: "Title", table: "Notes"))
            .toolbar {
                if library.status == .ready {
                    ToolbarItem {
                        NoteSortMenu(sortOrder: $sortOrder)
                    }
                }
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
            NotesListView(selection: $selection, sortOrder: sortOrder, onRename: onRename, onTrash: onTrash)
        }
    }
}
