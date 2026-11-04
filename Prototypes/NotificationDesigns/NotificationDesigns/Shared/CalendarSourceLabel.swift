import SwiftUI

struct CalendarSourceLabel: View {
    let alert: SampleAlert

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(alert.color)
                .frame(width: 9, height: 9)
            HStack(spacing: 4) {
                Text(alert.accountName)
                    .lineLimit(1)
                Text("·")
                Text(alert.calendarName)
                    .lineLimit(1)
                    .layoutPriority(1)
            }
        }
        .font(.footnote.weight(.medium))
        .foregroundStyle(.secondary)
    }
}
