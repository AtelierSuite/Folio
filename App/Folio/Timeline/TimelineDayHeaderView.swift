import Planner
import SwiftUI

struct TimelineDayHeaderView: View {
    let days: TimelineDays
    let gutterWidth: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            Color.clear
                .frame(width: gutterWidth, height: 1)
            ForEach(days.intervals, id: \.start) { day in
                TimelineDayHeaderLabel(day: day, calendar: days.calendar)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 6)
    }
}

struct TimelineDayHeaderLabel: View {
    let day: DateInterval
    let calendar: Calendar

    var body: some View {
        let isToday = calendar.isDateInToday(day.start)
        VStack(spacing: 2) {
            Text(day.start.formatted(Date.FormatStyle(timeZone: calendar.timeZone).weekday(.abbreviated)))
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(day.start.formatted(Date.FormatStyle(timeZone: calendar.timeZone).day()))
                .font(.callout.weight(isToday ? .bold : .regular))
                .foregroundStyle(isToday ? .white : .primary)
                .lineLimit(1)
                .fixedSize()
                .padding(.horizontal, 6)
                .frame(minWidth: 26, minHeight: 26)
                .background(isToday ? Color.red : Color.clear, in: Capsule())
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(day.start.formatted(Date.FormatStyle(date: .complete, timeZone: calendar.timeZone)))
    }
}
