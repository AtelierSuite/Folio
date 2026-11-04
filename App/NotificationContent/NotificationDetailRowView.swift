import Planner
import SwiftUI

struct NotificationDetailRowView: View {
    let row: NotificationDetailRow

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Image(systemName: row.systemImage)
                .foregroundStyle(.secondary)
            Text(row.text)
                .lineLimit(2)
        }
        .font(.subheadline)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("NotificationDetail.\(row.id)")
    }
}
