import Foundation
import Testing
@testable import Planner

struct TimelineStripTests {
    typealias Support = TimelineTestSupport

    private func mondayCalendar() -> Calendar {
        var calendar = Support.calendar()
        calendar.firstWeekday = 2
        return calendar
    }

    @Test func dayPagesAreConsecutiveDaysAroundTheDate() {
        let strip = TimelineStrip(
            unit: .day, around: Support.date(2026, 10, 30, 15), window: SlidingPageWindow(radius: 2),
            calendar: Support.calendar()
        )
        #expect(strip.pages == (28...32).map { Support.date(2026, 10, $0) })
        #expect(strip.daysPerPage == 1)
        #expect(strip.days.count == 5)
        #expect(strip.days.intervals.first?.start == Support.date(2026, 10, 28))
    }

    @Test func dayPagesStartAtMidnightAcrossDaylightSavingChange() {
        let strip = TimelineStrip(
            unit: .day, around: Support.date(2026, 11, 1), window: SlidingPageWindow(radius: 1),
            calendar: Support.calendar()
        )
        #expect(strip.pages == [Support.date(2026, 10, 31), Support.date(2026, 11, 1), Support.date(2026, 11, 2)])
        #expect(strip.days.intervals[1].duration == 25 * 3600)
    }

    @Test func weekPagesStartOnTheFirstWeekday() {
        let strip = TimelineStrip(
            unit: .week(workdays: nil), around: Support.date(2026, 10, 30), window: SlidingPageWindow(radius: 1),
            calendar: mondayCalendar()
        )
        #expect(strip.pages == [Support.date(2026, 10, 19), Support.date(2026, 10, 26), Support.date(2026, 11, 2)])
        #expect(strip.daysPerPage == 7)
        #expect(strip.days.count == 21)
        #expect(strip.dayRange(ofPageAt: 1) == 7..<14)
    }

    @Test func workWeekPagesOnlyHoldWorkdays() {
        let strip = TimelineStrip(
            unit: .week(workdays: [2, 3, 5]), around: Support.date(2026, 10, 30), window: SlidingPageWindow(radius: 1),
            calendar: mondayCalendar()
        )
        #expect(strip.daysPerPage == 3)
        let middle = strip.dayRange(ofPageAt: 1).map { strip.days.intervals[$0].start }
        #expect(middle == [Support.date(2026, 10, 26), Support.date(2026, 10, 27), Support.date(2026, 10, 29)])
    }

    @Test func emptyWorkdaysFallBackToTheWholeWeek() {
        let strip = TimelineStrip(
            unit: .week(workdays: []), around: Support.date(2026, 10, 30), window: SlidingPageWindow(radius: 0),
            calendar: mondayCalendar()
        )
        #expect(strip.daysPerPage == 7)
    }

    @Test func recentersOncePastTheDistanceOrOffTheStrip() {
        let strip = TimelineStrip(
            unit: .day, around: Support.date(2026, 10, 30),
            window: SlidingPageWindow(radius: 6, recenteringDistance: 2), calendar: Support.calendar()
        )
        #expect(!strip.needsRecentering(on: Support.date(2026, 11, 1)))
        #expect(strip.needsRecentering(on: Support.date(2026, 11, 2)))
        #expect(strip.needsRecentering(on: Support.date(2027, 1, 1)))
        let recentered = strip.recentered(on: Support.date(2026, 11, 2, 9))
        #expect(recentered.pages[6] == Support.date(2026, 11, 2))
        #expect(recentered.pages.contains(Support.date(2026, 10, 30)))
    }

    @Test func movingADateOntoAWeekKeepsTheWeekday() {
        let strip = TimelineStrip(
            unit: .week(workdays: nil), around: Support.date(2026, 10, 30), window: SlidingPageWindow(radius: 2),
            calendar: mondayCalendar()
        )
        let thursday = Support.date(2026, 10, 29)
        #expect(strip.date(thursday, movedToPage: Support.date(2026, 11, 9)) == Support.date(2026, 11, 12))
        #expect(strip.date(thursday, movedToPage: Support.date(2026, 10, 19)) == Support.date(2026, 10, 22))
    }

    @Test func movingADateOntoADayIsThatDay() {
        let strip = TimelineStrip(
            unit: .day, around: Support.date(2026, 10, 30), window: SlidingPageWindow(radius: 2),
            calendar: Support.calendar()
        )
        #expect(strip.date(Support.date(2026, 10, 30), movedToPage: Support.date(2026, 11, 1)) == Support.date(2026, 11, 1))
    }

    @Test func intervalsAroundAPageAreClampedToTheStrip() {
        let strip = TimelineStrip(
            unit: .day, around: Support.date(2026, 10, 30), window: SlidingPageWindow(radius: 3),
            calendar: Support.calendar()
        )
        let starts = strip.intervals(aroundPage: Support.date(2026, 11, 1), pageRadius: 2).map(\.start)
        #expect(starts == [Support.date(2026, 10, 30), Support.date(2026, 10, 31), Support.date(2026, 11, 1),
                           Support.date(2026, 11, 2)])
        #expect(strip.intervals(aroundPage: Support.date(2027, 1, 1), pageRadius: 2).isEmpty)
    }
}
