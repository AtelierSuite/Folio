import Foundation
import Testing
@testable import Planner

struct StandaloneAlarmSuggestedFireDateTests {
    private let now = Fixtures.date(2026, 11, 3, hour: 10).addingTimeInterval(20 * 60)
    private let calendar = Fixtures.calendar

    @Test func keepsATappedTimeInTheFuture() {
        let tapped = Fixtures.date(2026, 11, 3, hour: 15)
        #expect(StandaloneAlarm.suggestedFireDate(at: tapped, hasTime: true, now: now, calendar: calendar) == tapped)
    }

    @Test func suggestsSevenInTheMorningForAWholeDay() {
        let day = Fixtures.date(2026, 11, 5)
        let suggested = StandaloneAlarm.suggestedFireDate(at: day, hasTime: false, now: now, calendar: calendar)
        #expect(suggested == Fixtures.date(2026, 11, 5, hour: 7))
    }

    @Test func movesAPassedTimeToTheNextWholeHour() {
        let today = Fixtures.date(2026, 11, 3)
        let nextHour = Fixtures.date(2026, 11, 3, hour: 11)
        #expect(StandaloneAlarm.suggestedFireDate(at: today, hasTime: false, now: now, calendar: calendar) == nextHour)
        let earlier = Fixtures.date(2026, 11, 3, hour: 9)
        #expect(StandaloneAlarm.suggestedFireDate(at: earlier, hasTime: true, now: now, calendar: calendar) == nextHour)
    }
}
