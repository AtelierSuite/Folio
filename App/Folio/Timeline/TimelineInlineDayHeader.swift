import Planner
import SwiftUI

struct TimelineInlineDayHeader: View {
    @Environment(\.alternateCalendarFormatter) private var alternateCalendarFormatter
    @Environment(\.dayHighlighter) private var dayHighlighter
    let day: DateInterval
    let calendar: Calendar
    var showsDayLabels = true

    private var isToday: Bool {
        calendar.isDateInToday(day.start)
    }

    private var isHighlighted: Bool {
        dayHighlighter.isHighlighted(day.start, calendar: calendar)
    }

    private var numberStyle: AnyShapeStyle {
        if isToday {
            return AnyShapeStyle(.white)
        }
        return isHighlighted ? AnyShapeStyle(Color.dayHighlight) : AnyShapeStyle(.primary)
    }

    var body: some View {
        HStack(spacing: 6) {
            if showsDayLabels {
                dayLabel
            }
            Spacer(minLength: 4)
            TimelineDayHeaderWeather(dayStart: day.start, font: .subheadline, dropsTemperaturesToFit: true)
        }
        .font(.subheadline)
        .lineLimit(1)
        .padding(.horizontal, 8)
    }

    private var dayLabel: some View {
        HStack(spacing: 4) {
            Text(day.start.formatted(Date.FormatStyle(timeZone: calendar.timeZone).day()))
                .fontWeight(isToday ? .bold : .semibold)
                .monospacedDigit()
                .foregroundStyle(numberStyle)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(isToday ? Color.accentColor : .clear, in: Capsule())
                .padding(.leading, -6)
            Text(day.start.formatted(Date.FormatStyle(timeZone: calendar.timeZone).weekday(.abbreviated)))
                .foregroundStyle(isHighlighted ? AnyShapeStyle(Color.dayHighlight) : AnyShapeStyle(.secondary))
            AlternateCalendarDayLabel(date: day.start, font: .subheadline)
        }
        .fixedSize()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        let labels = [
            day.start.formatted(Date.FormatStyle(date: .complete, timeZone: calendar.timeZone)),
            alternateCalendarFormatter?.fullDate(for: day.start),
            dayHighlighter.holidayName(on: day.start, calendar: calendar)
        ]
        return labels.compactMap(\.self).joined(separator: ", ")
    }
}
