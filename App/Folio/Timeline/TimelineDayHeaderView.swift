import Planner
import SwiftUI

struct TimelineDayHeaderView: View {
    let days: TimelineDays
    let pages: TimelinePages
    let frames: TimelinePageFrames
    let scrolledPage: Date?
    let gutterWidth: CGFloat
    var gutterLayers: [TimelineLayer] = []
    var showsDayLabels = true

    var body: some View {
        HStack(spacing: 0) {
            ForEach(gutterLayers) { layer in
                (layer.header ?? AnyView(Color.clear))
                    .frame(width: layer.gutterWidth)
            }
            Color.clear
                .frame(width: gutterWidth - gutterLayers.reduce(0) { $0 + $1.gutterWidth }, height: 1)
            TimelinePagedRow(frames: frames, pages: pages, scrolledPage: scrolledPage) { page in
                TimelinePageHeaderView(
                    intervals: intervals(of: page), calendar: days.calendar, showsDayLabels: showsDayLabels
                )
            }
        }
        .padding(.vertical, showsDayLabels ? 6 : 2)
    }

    private func intervals(of page: Date) -> ArraySlice<DateInterval> {
        guard let range = pages.dayRange(of: page) else { return [] }
        return days.intervals[range.clamped(to: days.intervals.indices)]
    }
}

struct TimelinePageHeaderView: View {
    let intervals: ArraySlice<DateInterval>
    let calendar: Calendar
    var showsDayLabels = true

    var body: some View {
        HStack(spacing: 0) {
            ForEach(intervals, id: \.start) { day in
                VStack(spacing: 2) {
                    if showsDayLabels {
                        TimelineDayHeaderLabel(day: day, calendar: calendar)
                    }
                    TimelineDayHeaderWeather(dayStart: day.start)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct TimelineDayHeaderLabel: View {
    @Environment(\.alternateCalendarFormatter) private var alternateCalendarFormatter
    @Environment(\.dayHighlighter) private var dayHighlighter
    let day: DateInterval
    let calendar: Calendar
    /// When set, the selected day gets the filled number instead of today, which keeps its colour.
    var isSelected: Bool?
    @ScaledMetric(relativeTo: .callout) private var selectorDiameter: CGFloat = 32

    private var isToday: Bool {
        calendar.isDateInToday(day.start)
    }

    private var isHighlighted: Bool {
        dayHighlighter.isHighlighted(day.start, calendar: calendar)
    }

    private var isFilled: Bool {
        isSelected ?? isToday
    }

    private var numberStyle: AnyShapeStyle {
        if isFilled {
            return isToday ? AnyShapeStyle(.white) : AnyShapeStyle(.background)
        }
        if isToday {
            return AnyShapeStyle(Color.accentColor)
        }
        return isHighlighted ? AnyShapeStyle(Color.dayHighlight) : AnyShapeStyle(.primary)
    }

    private var numberFill: Color {
        guard isFilled else { return .clear }
        return isToday ? .accentColor : .primary
    }

    var body: some View {
        VStack(spacing: 2) {
            Text(day.start.formatted(Date.FormatStyle(timeZone: calendar.timeZone).weekday(.abbreviated)))
                .font(.caption2)
                .foregroundStyle(isHighlighted ? AnyShapeStyle(Color.dayHighlight) : AnyShapeStyle(.secondary))
            dayNumber
                .font(.callout.weight(isToday || isFilled ? .bold : .regular))
                .foregroundStyle(numberStyle)
                .lineLimit(1)
                .fixedSize()
            AlternateCalendarDayLabel(date: day.start)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    @ViewBuilder
    private var dayNumber: some View {
        if isSelected == nil {
            Text(day.start.formatted(Date.FormatStyle(timeZone: calendar.timeZone).day()))
                .padding(.horizontal, 6)
                .frame(minWidth: 26, minHeight: 26)
                .background(numberFill, in: Capsule())
        } else {
            Text(calendar.component(.day, from: day.start), format: .number)
                .monospacedDigit()
                .frame(width: selectorDiameter, height: selectorDiameter)
                .background(numberFill, in: Circle())
        }
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
