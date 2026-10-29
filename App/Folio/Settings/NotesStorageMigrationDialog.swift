import Planner
import SwiftUI

struct NotesStorageChange: Identifiable {
    let id = UUID()
    let mode: NotesStorageMode
    let folderURL: URL?
}

extension View {
    func notesStorageMigrationDialog(
        change: Binding<NotesStorageChange?>,
        onConfirm: @escaping (NotesStorageChange, Bool) -> Void
    ) -> some View {
        confirmationDialog(
            String(localized: "Storage.Migrate.Title", table: "Notes"),
            isPresented: Binding(
                get: { change.wrappedValue != nil },
                set: { isPresented in
                    if !isPresented {
                        change.wrappedValue = nil
                    }
                }
            ),
            titleVisibility: .visible,
            presenting: change.wrappedValue
        ) { pendingChange in
            Button(String(localized: "Storage.Migrate.Move", table: "Notes")) {
                onConfirm(pendingChange, true)
            }
            Button(String(localized: "Storage.Migrate.Skip", table: "Notes")) {
                onConfirm(pendingChange, false)
            }
            Button(String(localized: "Action.Cancel", table: "Notes"), role: .cancel) {}
        } message: { _ in
            Text(String(localized: "Storage.Migrate.Message", table: "Notes"))
        }
    }
}
