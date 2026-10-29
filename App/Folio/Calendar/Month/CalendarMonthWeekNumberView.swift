import SwiftUI

struct CalendarMonthWeekNumberView: View {
    let weekNumber: Int
    let width: CGFloat

    var body: some View {
        Text(weekNumber, format: .number)
            .font(.caption2.monospacedDigit())
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .padding(.top, 6)
            .frame(width: width)
            .frame(maxHeight: .infinity, alignment: .top)
            .accessibilityLabel(String(localized: "Accessibility.WeekNumber \(weekNumber)", table: "Month"))
    }
}
