import Foundation
@testable import Planner

enum MonthTestSupport {
    static let newYork = TimeZone(identifier: "America/New_York")!

    static func calendar(locale identifier: String = "en_US", firstWeekday: Int? = nil) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = newYork
        calendar.locale = Locale(identifier: identifier)
        if let firstWeekday {
            calendar.firstWeekday = firstWeekday
        }
        return calendar
    }

    static func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 0, _ minute: Int = 0) -> Date {
        TimelineTestSupport.date(year, month, day, hour, minute)
    }

    static func grid(_ year: Int, _ month: Int, calendar: Calendar = calendar()) -> MonthGrid {
        MonthGrid(containing: date(year, month, 15), calendar: calendar)
    }

    static func entry(
        _ id: String, from start: Date, to end: Date, isAllDay: Bool = false, kind: TimelineEntryKind = .event
    ) -> TimelineEntry {
        TimelineEntry(
            id: id, title: id, start: start, end: end, isAllDay: isAllDay,
            timeZone: isAllDay ? nil : newYork, color: TimelineTestSupport.gray, kind: kind
        )
    }
}
