import Foundation

struct TimelineEntryResolver {
    let calendar: Calendar
    let floatingSourceTimeZone: TimeZone

    func interval(for entry: TimelineEntry) -> DateInterval {
        if entry.isAllDay {
            return allDayInterval(for: entry)
        }
        guard entry.isFloating else {
            return DateInterval(start: entry.start, end: max(entry.start, entry.end))
        }
        let start = keepingWallClock(of: entry.start, from: floatingSourceTimeZone)
        let end = keepingWallClock(of: entry.end, from: floatingSourceTimeZone)
        return DateInterval(start: start, end: max(start, end))
    }

    private func allDayInterval(for entry: TimelineEntry) -> DateInterval {
        let sourceTimeZone = entry.timeZone ?? floatingSourceTimeZone
        let lastMoment = entry.end > entry.start ? entry.end.addingTimeInterval(-1) : entry.start
        let firstDayNoon = noon(onSameDayAs: entry.start, from: sourceTimeZone)
        let lastDayNoon = noon(onSameDayAs: lastMoment, from: sourceTimeZone)
        let nextDayNoon = calendar.date(byAdding: .day, value: 1, to: lastDayNoon) ?? lastDayNoon
        return DateInterval(start: calendar.startOfDay(for: firstDayNoon), end: calendar.startOfDay(for: nextDayNoon))
    }

    private func keepingWallClock(of date: Date, from sourceTimeZone: TimeZone) -> Date {
        var sourceCalendar = calendar
        sourceCalendar.timeZone = sourceTimeZone
        let components = sourceCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        return calendar.date(from: components) ?? date
    }

    private func noon(onSameDayAs date: Date, from sourceTimeZone: TimeZone) -> Date {
        var sourceCalendar = calendar
        sourceCalendar.timeZone = sourceTimeZone
        var components = sourceCalendar.dateComponents([.year, .month, .day], from: date)
        components.hour = 12
        return calendar.date(from: components) ?? date
    }
}
