import Foundation

/// Dates as Siri and Shortcuts show them: just the time for today, the date and time otherwise.
public enum IntentDateText {
    public static func time(_ date: Date, now: Date = .now, calendar: Calendar = .current) -> String {
        let dateStyle: Date.FormatStyle.DateStyle = calendar.isDate(date, inSameDayAs: now) ? .omitted : .abbreviated
        return date.formatted(Date.FormatStyle(date: dateStyle, time: .shortened, timeZone: calendar.timeZone))
    }

    public static func day(_ date: Date, calendar: Calendar = .current) -> String {
        date.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted, timeZone: calendar.timeZone))
    }

    public static func timeRange(
        from start: Date,
        to end: Date,
        isAllDay: Bool,
        calendar: Calendar = .current
    ) -> String {
        guard !isAllDay else { return day(start, calendar: calendar) }
        guard end > start else { return time(start, now: .distantPast, calendar: calendar) }
        var style = Date.IntervalFormatStyle(date: .abbreviated, time: .shortened)
        style.timeZone = calendar.timeZone
        return (start..<end).formatted(style)
    }
}
