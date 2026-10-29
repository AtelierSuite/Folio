import Foundation
@testable import Planner

enum TimelineTestSupport {
    static let newYork = TimeZone(identifier: "America/New_York")!
    static let tokyo = TimeZone(identifier: "Asia/Tokyo")!
    static let gray = TimelineColor(red: 0.5, green: 0.5, blue: 0.5)

    static func calendar(in timeZone: TimeZone = newYork) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar
    }

    static func date(
        _ year: Int, _ month: Int, _ day: Int, _ hour: Int = 0, _ minute: Int = 0,
        in timeZone: TimeZone = newYork
    ) -> Date {
        let components = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)
        return calendar(in: timeZone).date(from: components)!
    }

    static func entry(
        _ id: String, from start: Date, to end: Date, isAllDay: Bool = false, timeZone: TimeZone? = newYork
    ) -> TimelineEntry {
        TimelineEntry(id: id, title: id, start: start, end: end, isAllDay: isAllDay, timeZone: timeZone, color: gray)
    }

    static func engine(startingOn date: Date, count: Int, in timeZone: TimeZone = newYork) -> TimelineLayoutEngine {
        let days = TimelineDays(startingOn: date, count: count, calendar: calendar(in: timeZone))
        return TimelineLayoutEngine(days: days, floatingSourceTimeZone: tokyo, minimumEntryDuration: 15 * 60)
    }
}
