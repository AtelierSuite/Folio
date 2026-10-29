import SwiftUI

struct RecentlyDeletedToolbar: ToolbarContent {
    let canEmpty: Bool
    let onEmpty: () -> Void
    let onDone: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button(String(localized: "Action.Done", table: "Notes"), action: onDone)
        }
        ToolbarItem(placement: .destructiveAction) {
            Button(String(localized: "Trash.EmptyTrash", table: "Notes"), role: .destructive, action: onEmpty)
                .disabled(!canEmpty)
        }
    }
}
