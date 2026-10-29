import Planner
import SwiftUI

struct RecentlyDeletedView: View {
    @Environment(NotesLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @State private var isConfirmingEmptyTrash = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                ForEach(library.trashedNotes) { file in
                    TrashedNoteRowView(file: file, onRestore: { restore(file) }, onDelete: { delete(file) })
                }
            }
            .overlay {
                if library.trashedNotes.isEmpty {
                    ContentUnavailableView(
                        String(localized: "Trash.Empty.Title", table: "Notes"),
                        systemImage: "trash",
                        description: Text(String(localized: "Trash.Empty.Description", table: "Notes"))
                    )
                }
            }
            .navigationTitle(String(localized: "List.RecentlyDeleted", table: "Notes"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                RecentlyDeletedToolbar(
                    canEmpty: !library.trashedNotes.isEmpty,
                    onEmpty: { isConfirmingEmptyTrash = true },
                    onDone: { dismiss() }
                )
            }
            .confirmationDialog(
                String(localized: "Trash.EmptyTrash.Confirmation", table: "Notes"),
                isPresented: $isConfirmingEmptyTrash,
                titleVisibility: .visible
            ) {
                Button(String(localized: "Trash.EmptyTrash", table: "Notes"), role: .destructive, action: emptyTrash)
            } message: {
                Text(String(localized: "Trash.EmptyTrash.Message", table: "Notes"))
            }
            .notesErrorAlert(message: $errorMessage)
        }
        .task {
            await library.refresh()
        }
        #if os(macOS)
        .frame(minWidth: 420, minHeight: 360)
        #endif
    }

    private func restore(_ file: NoteFile) {
        perform { try await library.restore(file.url) }
    }

    private func delete(_ file: NoteFile) {
        perform { try await library.deletePermanently(file.url) }
    }

    private func emptyTrash() {
        perform { try await library.emptyTrash() }
    }

    private func perform(_ action: @escaping () async throws -> Void) {
        Task {
            do {
                try await action()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
