import SwiftUI

struct CalendarMonthMoreLabel: View {
    let count: Int

    var body: some View {
        ViewThatFits(in: .horizontal) {
            Text(String(localized: "Cell.More \(count)", table: "Month"))
            Text(String(localized: "Cell.MoreCompact \(count)", table: "Month"))
        }
        .font(.caption2.weight(.medium))
        .foregroundStyle(.secondary)
        .lineLimit(1)
        .padding(.horizontal, 3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "Cell.More \(count)", table: "Month"))
    }
}
