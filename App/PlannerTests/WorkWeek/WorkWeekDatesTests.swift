import Foundation
import Testing
@testable import Planner

struct WorkWeekDatesTests {
    typealias Support = TimelineTestSupport

    @Test func weekStartsOnTheLocaleFirstWeekday() {
        var calendar = Support.calendar()
        calendar.firstWeekday = 2
        let dates = calendar.weekDates(containing: Support.date(2026, 11, 1, 15))
        #expect(dates.first == Support.date(2026, 10, 26))
        #expect(dates.last == Support.date(2026, 11, 1))
        #expect(dates.count == 7)
    }

    @Test func workdayDatesSkipNonWorkdays() {
        var calendar = Support.calendar()
        calendar.firstWeekday = 2
        let dates = calendar.workdayDates(inWeekContaining: Support.date(2026, 10, 29), workdays: [2, 3, 5])
        #expect(dates == [Support.date(2026, 10, 26), Support.date(2026, 10, 27), Support.date(2026, 10, 29)])
    }

    @Test func sundayToThursdayWeekStartingSaturday() {
        var calendar = Support.calendar()
        calendar.firstWeekday = 7
        let dates = calendar.workdayDates(inWeekContaining: Support.date(2026, 10, 29), workdays: [1, 2, 3, 4, 5])
        #expect(dates.first == Support.date(2026, 10, 25))
        #expect(dates.last == Support.date(2026, 10, 29))
    }

    @Test func timelineDaysFromNonConsecutiveDates() {
        let calendar = Support.calendar()
        let days = TimelineDays(
            dates: [Support.date(2026, 10, 26, 9), Support.date(2026, 10, 27), Support.date(2026, 10, 29)],
            calendar: calendar
        )
        #expect(days.count == 3)
        #expect(days.intervals[2] == DateInterval(start: Support.date(2026, 10, 29), end: Support.date(2026, 10, 30)))
        #expect(days.span == DateInterval(start: Support.date(2026, 10, 26), end: Support.date(2026, 10, 30)))
        #expect(days.dayIndex(containing: Support.date(2026, 10, 28, 12)) == nil)
        #expect(days.position(of: Support.date(2026, 10, 29, 9)) == TimelineTimePosition(dayIndex: 2, hour: 9))
    }

    @Test func timelineDaysFromDatesKeepDaylightSavingLength() {
        let days = TimelineDays(dates: [Support.date(2026, 11, 1)], calendar: Support.calendar())
        #expect(days.intervals[0].duration == 25 * 3600)
    }

    @Test func eventOnASkippedDayIsHidden() {
        let dates = [Support.date(2026, 10, 27), Support.date(2026, 10, 29)]
        let days = TimelineDays(dates: dates, calendar: Support.calendar())
        let engine = TimelineLayoutEngine(days: days, floatingSourceTimeZone: Support.newYork)
        let layout = engine.layout([
            Support.entry("skipped", from: Support.date(2026, 10, 28, 9), to: Support.date(2026, 10, 28, 10)),
            Support.entry("shown", from: Support.date(2026, 10, 29, 9), to: Support.date(2026, 10, 29, 10)),
            Support.entry(
                "skippedAllDay", from: Support.date(2026, 10, 28), to: Support.date(2026, 10, 29),
                isAllDay: true, timeZone: nil
            )
        ])
        #expect(layout.timedPlacements.map(\.entry.id) == ["shown"])
        #expect(layout.allDayPlacements.isEmpty)
    }
}
