import SwiftUI

struct RecentlyDeletedToolbar: ToolbarContent {
    let canEmpty: Bool
    @Binding var isConfirmingEmptyTrash: Bool
    let onEmpty: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button(String(localized: "Trash.EmptyTrash", table: "Notes"), role: .destructive) {
                isConfirmingEmptyTrash = true
            }
            .disabled(!canEmpty)
            .confirmationDialog(
                String(localized: "Trash.EmptyTrash.Confirmation", table: "Notes"),
                isPresented: $isConfirmingEmptyTrash,
                titleVisibility: .visible
            ) {
                Button(String(localized: "Trash.EmptyTrash", table: "Notes"), role: .destructive, action: onEmpty)
            } message: {
                Text(String(localized: "Trash.EmptyTrash.Message", table: "Notes"))
            }
        }
    }
}
