import Planner
import SwiftUI

struct CalendarMonthDayNumberView: View {
    @Environment(\.dayHighlighter) private var dayHighlighter
    let day: MonthDay
    let calendar: Calendar
    let isToday: Bool

    var body: some View {
        Text(day.dayOfMonth, format: .number)
            .font(.caption.weight(isToday ? .bold : .medium).monospacedDigit())
            .foregroundStyle(foregroundStyle)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .padding(.horizontal, 4)
            .frame(minWidth: 20, minHeight: 20)
            .background(isToday ? Color.accentColor : Color.clear, in: Capsule())
            .accessibilityLabel(accessibilityLabel)
    }

    private var foregroundStyle: AnyShapeStyle {
        if isToday {
            return AnyShapeStyle(.white)
        }
        if dayHighlighter.isHighlighted(day.date, calendar: calendar) {
            return AnyShapeStyle(day.isInMonth ? Color.dayHighlight : Color.dayHighlight.opacity(0.4))
        }
        return day.isInMonth ? AnyShapeStyle(.primary) : AnyShapeStyle(.tertiary)
    }

    private var accessibilityLabel: String {
        let date = day.date.formatted(date: .complete, time: .omitted)
        guard let holidayName = dayHighlighter.holidayName(on: day.date, calendar: calendar) else { return date }
        return "\(date), \(holidayName)"
    }
}
