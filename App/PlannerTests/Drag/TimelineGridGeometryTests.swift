import CoreGraphics
import Foundation
import Testing
@testable import Planner

struct TimelineGridGeometryTests {
    typealias Support = TimelineTestSupport

    @Test func hourFromPositionFollowsTheZoomedHourHeight() {
        let fitted = TimelineGridGeometry(width: 300, dayCount: 1, hourHeight: 24.5)
        #expect(fitted.hour(atY: 24.5 * 9.5) == 9.5)
        let zoomed = TimelineGridGeometry(width: 300, dayCount: 1, hourHeight: 240)
        #expect(zoomed.hour(atY: 240 * 13.25) == 13.25)
        #expect(zoomed.y(ofHour: 2) == 480)
    }

    @Test func hourIsClampedToTheDay() {
        let geometry = TimelineGridGeometry(width: 300, dayCount: 1, hourHeight: 48)
        #expect(geometry.hour(atY: -20) == 0)
        #expect(geometry.hour(atY: 48 * 30) == 24)
    }

    @Test func dayFromPositionIsClampedToTheColumns() {
        let geometry = TimelineGridGeometry(width: 700, dayCount: 7, hourHeight: 48)
        #expect(geometry.dayIndex(atX: 0) == 0)
        #expect(geometry.dayIndex(atX: 99) == 0)
        #expect(geometry.dayIndex(atX: 100) == 1)
        #expect(geometry.dayIndex(atX: 650) == 6)
        #expect(geometry.dayIndex(atX: -30) == 0)
        #expect(geometry.dayIndex(atX: 900) == 6)
        #expect(abs(geometry.fractionWithinDay(atX: 125) - 0.25) < 0.0001)
    }

    @Test func pointUsesTheColumnsDate() {
        let calendar = Support.calendar()
        let days = TimelineDays(
            dates: [Support.date(2026, 10, 26), Support.date(2026, 10, 27), Support.date(2026, 10, 29)],
            calendar: calendar
        )
        let geometry = TimelineGridGeometry(width: 300, dayCount: 3, hourHeight: 48)
        let point = geometry.point(at: CGPoint(x: 250, y: 48 * 10), in: days)
        #expect(point == TimelineDragPoint(dayStart: Support.date(2026, 10, 29), hour: 10))
    }

    @Test func movingBetweenSkippedWorkdaysCountsCalendarDays() {
        let calendar = Support.calendar()
        let days = TimelineDays(dates: [Support.date(2026, 10, 27), Support.date(2026, 10, 29)], calendar: calendar)
        let origin = TimelineDragPoint(dayIndex: 0, hour: 9, in: days)!
        let operation = TimelineDragOperation(
            kind: .move,
            original: DateInterval(start: Support.date(2026, 10, 27, 9), duration: 3600),
            origin: origin,
            calendar: calendar
        )
        let interval = operation.interval(at: TimelineDragPoint(dayIndex: 1, hour: 9, in: days)!)
        #expect(interval.start == Support.date(2026, 10, 29, 9))
    }

    @Test func hourFromPositionOnADSTDayMapsToWallClockTime() {
        let calendar = Support.calendar()
        let days = TimelineDays(startingOn: Support.date(2026, 3, 8), count: 1, calendar: calendar)
        let geometry = TimelineGridGeometry(width: 300, dayCount: 1, hourHeight: 60)
        let point = geometry.point(at: CGPoint(x: 10, y: 60 * 5), in: days)!
        #expect(calendar.date(at: point) == Support.date(2026, 3, 8, 5))
    }
}
