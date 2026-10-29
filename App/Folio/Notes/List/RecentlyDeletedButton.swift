import SwiftUI

struct RecentlyDeletedButton: View {
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Label(String(localized: "List.RecentlyDeleted", table: "Notes"), systemImage: "trash")
                Spacer()
                if count > 0 {
                    Text(count, format: .number)
                        .foregroundStyle(.secondary)
                }
            }
            .contentShape(.rect)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .background(.bar)
    }
}
