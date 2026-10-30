import Planner
import SwiftUI

struct NotesListView: View {
    @Environment(NotesLibrary.self) private var library
    @Binding var selection: NotesSidebarItem?
    let onRename: (URL) -> Void
    let onTrash: (URL) -> Void

    var body: some View {
        List(selection: $selection) {
            Section {
                RecentlyDeletedRow(count: library.trashedNotes.count)
                    .tag(NotesSidebarItem.recentlyDeleted)
            }
            Section {
                ForEach(library.notes) { file in
                    NoteRowView(file: file)
                        .tag(NotesSidebarItem.note(file.url))
                        .contextMenu {
                            Button(String(localized: "Action.Rename", table: "Notes"), systemImage: "pencil") {
                                onRename(file.url)
                            }
                            trashButton(for: file)
                        }
                        .swipeActions {
                            trashButton(for: file)
                        }
                }
                if library.notes.isEmpty {
                    ContentUnavailableView(
                        String(localized: "Placeholder.Title", table: "Notes"),
                        systemImage: "note.text",
                        description: Text(String(localized: "Placeholder.Description", table: "Notes"))
                    )
                    .listRowBackground(Color.clear)
                }
            }
        }
        .refreshable {
            await library.refresh()
        }
    }

    private func trashButton(for file: NoteFile) -> some View {
        Button(String(localized: "Action.Delete", table: "Notes"), systemImage: "trash", role: .destructive) {
            onTrash(file.url)
        }
    }
}
