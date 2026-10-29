import Planner
import SwiftUI

struct CalendarMonthDayNumberView: View {
    let day: MonthDay
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
            .accessibilityLabel(day.date.formatted(date: .complete, time: .omitted))
    }

    private var foregroundStyle: AnyShapeStyle {
        if isToday {
            return AnyShapeStyle(.white)
        }
        return day.isInMonth ? AnyShapeStyle(.primary) : AnyShapeStyle(.tertiary)
    }
}
