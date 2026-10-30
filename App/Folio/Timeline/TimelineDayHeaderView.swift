import Planner
import SwiftUI

struct TimelineDayHeaderView: View {
    let days: TimelineDays
    let pages: TimelinePages
    let frames: TimelinePageFrames
    let scrolledPage: Date?
    let gutterWidth: CGFloat
    var gutterLayers: [TimelineLayer] = []

    var body: some View {
        HStack(spacing: 0) {
            ForEach(gutterLayers) { layer in
                (layer.header ?? AnyView(Color.clear))
                    .frame(width: layer.gutterWidth)
            }
            Color.clear
                .frame(width: gutterWidth - gutterLayers.reduce(0) { $0 + $1.gutterWidth }, height: 1)
            TimelinePagedRow(frames: frames, pages: pages, scrolledPage: scrolledPage) { page in
                TimelinePageHeaderView(intervals: intervals(of: page), calendar: days.calendar)
            }
        }
        .padding(.vertical, 6)
    }

    private func intervals(of page: Date) -> ArraySlice<DateInterval> {
        guard let range = pages.dayRange(of: page) else { return [] }
        return days.intervals[range.clamped(to: days.intervals.indices)]
    }
}

struct TimelinePageHeaderView: View {
    let intervals: ArraySlice<DateInterval>
    let calendar: Calendar

    var body: some View {
        HStack(spacing: 0) {
            ForEach(intervals, id: \.start) { day in
                VStack(spacing: 2) {
                    TimelineDayHeaderLabel(day: day, calendar: calendar)
                    TimelineDayHeaderWeather(dayStart: day.start)
                }
                .frame(maxWidth: .infinity)
            }
        }
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
                .background(isToday ? Color.accentColor : Color.clear, in: Capsule())
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(day.start.formatted(Date.FormatStyle(date: .complete, timeZone: calendar.timeZone)))
    }
}
