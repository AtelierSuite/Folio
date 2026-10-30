import SwiftUI

struct RecentlyDeletedToolbar: ToolbarContent {
    let canEmpty: Bool
    let onEmpty: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button(String(localized: "Trash.EmptyTrash", table: "Notes"), role: .destructive, action: onEmpty)
                .disabled(!canEmpty)
        }
    }
}
