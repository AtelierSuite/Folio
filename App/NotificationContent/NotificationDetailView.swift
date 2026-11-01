import Planner
import SwiftUI

struct NotificationDetailView: View {
    let detail: NotificationDetail

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(accentColor)
                .frame(width: 4)
            VStack(alignment: .leading, spacing: 6) {
                Text(detail.title)
                    .font(.headline)
                    .lineLimit(3)
                    .accessibilityIdentifier("NotificationDetail.Title")
                if let status = detail.status {
                    Text(status)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(accentColor)
                        .accessibilityIdentifier("NotificationDetail.Status")
                }
                ForEach(detail.rows) { row in
                    NotificationDetailRowView(row: row)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(16)
    }

    private var accentColor: Color {
        detail.color.map { Color(red: $0.red, green: $0.green, blue: $0.blue) } ?? .accentColor
    }
}
