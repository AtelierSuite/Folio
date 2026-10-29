import Foundation
import Testing
@testable import Planner

struct TimelineDaysTests {
    typealias Support = TimelineTestSupport

    @Test func daysStartAtMidnightAndFollowEachOther() {
        let days = TimelineDays(startingOn: Support.date(2026, 10, 28, 15), count: 3, calendar: Support.calendar())
        #expect(days.count == 3)
        #expect(days.intervals[0].start == Support.date(2026, 10, 28))
        #expect(days.intervals[2].end == Support.date(2026, 10, 31))
        #expect(days.intervals[0].end == days.intervals[1].start)
    }

    @Test func fallBackDayLastsTwentyFiveHours() {
        let days = TimelineDays(startingOn: Support.date(2026, 11, 1), count: 1, calendar: Support.calendar())
        #expect(days.intervals[0].duration == 25 * 3600)
    }

    @Test func springForwardDayLastsTwentyThreeHours() {
        let days = TimelineDays(startingOn: Support.date(2026, 3, 8), count: 1, calendar: Support.calendar())
        #expect(days.intervals[0].duration == 23 * 3600)
    }

    @Test func hourUsesWallClockOnDaylightSavingDays() {
        let springForward = TimelineDays(startingOn: Support.date(2026, 3, 8), count: 1, calendar: Support.calendar())
        #expect(springForward.hour(of: Support.date(2026, 3, 8, 3, 30), onDay: 0) == 3.5)
        #expect(springForward.hour(of: Support.date(2026, 3, 8, 23), onDay: 0) == 23)
        let fallBack = TimelineDays(startingOn: Support.date(2026, 11, 1), count: 1, calendar: Support.calendar())
        #expect(fallBack.hour(of: Support.date(2026, 11, 1, 22), onDay: 0) == 22)
    }

    @Test func hourClampsToTheDay() {
        let days = TimelineDays(startingOn: Support.date(2026, 10, 28), count: 1, calendar: Support.calendar())
        #expect(days.hour(of: Support.date(2026, 10, 27, 12), onDay: 0) == 0)
        #expect(days.hour(of: Support.date(2026, 10, 29), onDay: 0) == 24)
    }

    @Test func positionFindsTheDayAndHour() {
        let days = TimelineDays(startingOn: Support.date(2026, 10, 28), count: 3, calendar: Support.calendar())
        #expect(days.position(of: Support.date(2026, 10, 29, 9, 45)) == TimelineTimePosition(dayIndex: 1, hour: 9.75))
        #expect(days.position(of: Support.date(2026, 11, 2)) == nil)
    }

    @Test func dateAtHourRoundTrips() {
        let days = TimelineDays(startingOn: Support.date(2026, 3, 8), count: 1, calendar: Support.calendar())
        #expect(days.date(atHour: 14.5, onDay: 0) == Support.date(2026, 3, 8, 14, 30))
        #expect(days.date(atHour: 24, onDay: 0) == Support.date(2026, 3, 9))
    }

    @Test func segmentsSplitAtMidnight() {
        let days = TimelineDays(startingOn: Support.date(2026, 10, 28), count: 3, calendar: Support.calendar())
        let segments = days.segments(from: Support.date(2026, 10, 28, 22), to: Support.date(2026, 10, 29, 2, 30))
        #expect(segments == [
            TimelineDaySegment(
                dayIndex: 0, startHour: 22, endHour: 24, continuesFromPreviousDay: false, continuesToNextDay: true
            ),
            TimelineDaySegment(
                dayIndex: 1, startHour: 0, endHour: 2.5, continuesFromPreviousDay: true, continuesToNextDay: false
            )
        ])
    }

    @Test func segmentEndingAtMidnightStaysOnOneDay() {
        let days = TimelineDays(startingOn: Support.date(2026, 10, 28), count: 2, calendar: Support.calendar())
        let segments = days.segments(from: Support.date(2026, 10, 28, 23), to: Support.date(2026, 10, 29))
        #expect(segments.count == 1)
        #expect(segments[0].endHour == 24)
        #expect(!segments[0].continuesToNextDay)
    }

    @Test func instantBelongsToOneDay() {
        let days = TimelineDays(startingOn: Support.date(2026, 10, 28), count: 2, calendar: Support.calendar())
        let segments = days.segments(from: Support.date(2026, 10, 29), to: Support.date(2026, 10, 29))
        #expect(segments.map(\.dayIndex) == [1])
    }

    @Test func segmentAcrossRepeatedHourKeepsItsLength() {
        let days = TimelineDays(startingOn: Support.date(2026, 11, 1), count: 1, calendar: Support.calendar())
        let firstOneThirty = Support.date(2026, 11, 1, 1, 30)
        let segments = days.segments(from: firstOneThirty, to: firstOneThirty.addingTimeInterval(45 * 60))
        #expect(segments[0].startHour == 1.5)
        #expect(segments[0].endHour == 2.25)
    }

    @Test func segmentAcrossSkippedHourUsesWallClock() {
        let days = TimelineDays(startingOn: Support.date(2026, 3, 8), count: 1, calendar: Support.calendar())
        let segments = days.segments(from: Support.date(2026, 3, 8, 1, 30), to: Support.date(2026, 3, 8, 3, 30))
        #expect(segments[0].startHour == 1.5)
        #expect(segments[0].endHour == 3.5)
    }
}
