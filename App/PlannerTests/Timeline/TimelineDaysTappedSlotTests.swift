import Foundation
import Testing
@testable import Planner

struct TimelineDaysTappedSlotTests {
    typealias Support = TimelineTestSupport

    private let days = TimelineDays(
        startingOn: Support.date(2026, 10, 28), count: 3, calendar: Support.calendar()
    )

    @Test func snapsDownToTheSlotTheTapFallsIn() {
        #expect(days.startOfSlot(onDay: 1, atHour: 10.67, snap: .fifteenMinutes) == Support.date(2026, 10, 29, 10, 30))
        #expect(days.startOfSlot(onDay: 1, atHour: 10.67, snap: .fiveMinutes) == Support.date(2026, 10, 29, 10, 40))
    }

    @Test func keepsTheSlotInsideTheDay() {
        #expect(days.startOfSlot(onDay: 0, atHour: -1, snap: .fifteenMinutes) == Support.date(2026, 10, 28))
        #expect(days.startOfSlot(onDay: 0, atHour: 24, snap: .fifteenMinutes) == Support.date(2026, 10, 28, 23, 45))
    }

    @Test func returnsNilOutsideTheDays() {
        #expect(days.startOfSlot(onDay: 3, atHour: 9, snap: .fifteenMinutes) == nil)
    }

    @Test func usesWallClockHoursOnDaylightSavingDays() {
        let fallBack = TimelineDays(startingOn: Support.date(2026, 11, 1), count: 1, calendar: Support.calendar())
        #expect(fallBack.startOfSlot(onDay: 0, atHour: 14, snap: .fifteenMinutes) == Support.date(2026, 11, 1, 14))
    }
}
