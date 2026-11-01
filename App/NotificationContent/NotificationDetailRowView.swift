import Planner
import SwiftUI

struct NotificationDetailRowView: View {
    let row: NotificationDetailRow

    var body: some View {
        Label {
            Text(row.text)
                .lineLimit(2)
        } icon: {
            Image(systemName: row.systemImage)
                .foregroundStyle(.secondary)
        }
        .font(.subheadline)
        .accessibilityIdentifier("NotificationDetail.\(row.id)")
    }
}
