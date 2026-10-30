import SwiftUI

struct RecentlyDeletedRow: View {
    let count: Int

    var body: some View {
        Label(String(localized: "List.RecentlyDeleted", table: "Notes"), systemImage: "trash")
            .badge(count)
    }
}
