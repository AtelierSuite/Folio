import Foundation
import Testing
@testable import Planner

struct CalendarDayMoveTests {
    typealias Support = TimelineTestSupport

    @Test func timedEventsKeepTheirTimeAndLength() {
        let interval = DateInterval(start: Support.date(2026, 10, 27, 15), end: Support.date(2026, 10, 27, 16, 30))
        let moved = CalendarDayMove.interval(
            interval, isAllDay: false, from: Support.date(2026, 10, 27), to: Support.date(2026, 11, 3),
            calendar: Support.calendar()
        )
        #expect(moved.start == Support.date(2026, 11, 3, 15))
        #expect(moved.duration == 90 * 60)
    }

    @Test func allDayEventsKeepTheirDayCountAcrossDST() {
        let interval = DateInterval(start: Support.date(2026, 10, 30), end: Support.date(2026, 11, 1))
        let moved = CalendarDayMove.interval(
            interval, isAllDay: true, from: Support.date(2026, 10, 31), to: Support.date(2026, 11, 1),
            calendar: Support.calendar()
        )
        #expect(moved.start == Support.date(2026, 10, 31))
        #expect(moved.end == Support.date(2026, 11, 2))
    }

    @Test func timedEventsKeepTheirWallClockTimeAcrossDST() {
        let interval = DateInterval(start: Support.date(2026, 3, 7, 9), duration: 3600)
        let moved = CalendarDayMove.interval(
            interval, isAllDay: false, from: Support.date(2026, 3, 7), to: Support.date(2026, 3, 9),
            calendar: Support.calendar()
        )
        #expect(moved.start == Support.date(2026, 3, 9, 9))
    }

    @Test func remindersMoveByDays() {
        let moved = CalendarDayMove.date(
            Support.date(2026, 10, 27, 17), from: Support.date(2026, 10, 27), to: Support.date(2026, 10, 25),
            calendar: Support.calendar()
        )
        #expect(moved == Support.date(2026, 10, 25, 17))
    }
}
