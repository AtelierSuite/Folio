#if DEBUG
import Foundation
import Planner

extension TimelineDebugSampleWeek {
    func date(_ dayOffset: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: weekStart) ?? weekStart
        let dayNoon = calendar.date(byAdding: .day, value: dayOffset + hour / 24, to: noon) ?? noon
        let day = calendar.startOfDay(for: dayNoon)
        return calendar.date(bySettingHour: hour % 24, minute: minute, second: 0, of: day) ?? day
    }

    func timed(
        _ key: String, _ dayOffset: Int,
        from start: (hour: Int, minute: Int), to end: (hour: Int, minute: Int), color: TimelineColor
    ) -> TimelineEntry {
        let startDate = date(dayOffset, start.hour, start.minute)
        return entry(key, start: startDate, end: date(dayOffset, end.hour, end.minute), color: color)
    }

    func entry(
        _ key: String, start: Date, end: Date, color: TimelineColor,
        timeZone: TimeZone? = nil, kind: TimelineEntryKind = .event, isAllDay: Bool = false, isReadOnly: Bool = false
    ) -> TimelineEntry {
        TimelineEntry(
            id: "\(key)-\(start.timeIntervalSinceReferenceDate)",
            title: String(localized: String.LocalizationValue(key), table: "Timeline"),
            start: start,
            end: end,
            isAllDay: isAllDay,
            timeZone: timeZone ?? calendar.timeZone,
            color: color,
            isReadOnly: isReadOnly,
            kind: kind
        )
    }

    func allDay(
        _ key: String, from firstDay: Int, through lastDay: Int,
        color: TimelineColor, isReadOnly: Bool = false
    ) -> TimelineEntry {
        entry(
            key, start: date(firstDay, 0), end: date(lastDay + 1, 0), color: color,
            isAllDay: true, isReadOnly: isReadOnly
        )
    }

    func floatingRun(onDay dayOffset: Int) -> TimelineEntry {
        var floatingCalendar = calendar
        floatingCalendar.timeZone = floatingSourceTimeZone
        var components = calendar.dateComponents([.year, .month, .day], from: date(dayOffset, 12))
        components.hour = 7
        let start = floatingCalendar.date(from: components) ?? weekStart
        var run = entry("Sample.MorningRun", start: start, end: start + 45 * 60, color: .debugGreen)
        run.timeZone = nil
        return run
    }

    func tokyoCall(onDay dayOffset: Int) -> TimelineEntry {
        guard let tokyo = TimeZone(identifier: "Asia/Tokyo") else { return floatingRun(onDay: dayOffset) }
        var tokyoCalendar = calendar
        tokyoCalendar.timeZone = tokyo
        var components = calendar.dateComponents([.year, .month, .day], from: date(dayOffset, 12))
        components.hour = 9
        let start = tokyoCalendar.date(from: components) ?? weekStart
        return entry("Sample.TokyoCall", start: start, end: start + 3600, color: .debugRed, timeZone: tokyo)
    }
}

extension TimelineColor {
    static let debugBlue = TimelineColor(red: 0.2, green: 0.48, blue: 0.96)
    static let debugTeal = TimelineColor(red: 0.19, green: 0.69, blue: 0.78)
    static let debugGreen = TimelineColor(red: 0.2, green: 0.72, blue: 0.35)
    static let debugOrange = TimelineColor(red: 0.98, green: 0.58, blue: 0.13)
    static let debugRed = TimelineColor(red: 0.94, green: 0.27, blue: 0.27)
    static let debugPurple = TimelineColor(red: 0.62, green: 0.36, blue: 0.9)
    static let debugGray = TimelineColor(red: 0.55, green: 0.56, blue: 0.6)
}
#endif
