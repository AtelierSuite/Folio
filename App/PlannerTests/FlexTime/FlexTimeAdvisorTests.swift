import Foundation
import Testing
@testable import Planner

struct FlexTimeAdvisorTests {
    private typealias Fixture = FlexTimeFixtures
    private let advisor = FlexTimeAdvisor(calendar: Fixtures.calendar)

    @Test func wakingAfterTheFirstEventSuggestsStartingHalfAnHourLater() throws {
        let proposal = try #require(advisor.proposal(
            events: Fixture.morningEvents,
            wake: FlexTimeWake(time: Fixture.time(10, 30), source: .sleep),
            now: Fixture.time(10, 35),
            requiresNeed: true
        ))
        #expect(proposal.suggestedStart == Fixture.time(11))
        #expect(proposal.delay(startingFirstEventAt: proposal.suggestedStart) == 3 * 3600)
        #expect(proposal.events.map(\.title) == ["breakfast", "market", "lunch"])
        #expect(proposal.startRange.lowerBound == Fixture.time(8))
    }

    @Test func wakingInTimeNeedsNoFlexTime() {
        let proposal = advisor.proposal(
            events: Fixture.morningEvents,
            wake: FlexTimeWake(time: Fixture.time(7), source: .sleep),
            now: Fixture.time(10, 30),
            requiresNeed: true
        )
        #expect(proposal == nil)
    }

    @Test func dayWithoutTimedEventsNeedsNoFlexTime() {
        let yesterday = Fixtures.event(local: "dinner", start: Fixture.time(19, day: 30))
        let proposal = advisor.proposal(
            events: [yesterday],
            wake: FlexTimeWake(time: Fixture.time(10, 30), source: .firstOpen),
            now: Fixture.time(10, 30),
            requiresNeed: false
        )
        #expect(proposal == nil)
    }

    @Test func unknownWakeTimeOnlyProposesWhenAsked() throws {
        let events = Fixture.morningEvents
        #expect(advisor.proposal(events: events, wake: nil, now: Fixture.time(9), requiresNeed: true) == nil)
        let proposal = try #require(
            advisor.proposal(events: Fixture.morningEvents, wake: nil, now: Fixture.time(9, 5), requiresNeed: false)
        )
        #expect(proposal.suggestedStart == Fixture.time(9, 15))
    }

    @Test func activeDelayIsKeptAsTheSuggestion() throws {
        let delayed = FlexTimeSchedule(delays: [Fixture.day: 7200])
            .applying(to: Fixture.morningEvents, calendar: Fixtures.calendar)
        let proposal = try #require(advisor.proposal(
            events: delayed, wake: nil, now: Fixture.time(13), activeDelay: 7200, requiresNeed: false
        ))
        #expect(proposal.isActive)
        #expect(proposal.suggestedStart == Fixture.time(10))
        #expect(proposal.firstEvent?.startDate == Fixture.time(8))
    }

    @Test func wakeTimeIsTheEndOfTheLongestSleepEndingToday() {
        let sessions = [
            Fixture.night(endingAt: Fixture.time(10, 30)),
            Fixture.night(endingAt: Fixture.time(14), hours: 1)
        ]
        #expect(advisor.wakeTime(from: sessions, on: Fixture.time(15)) == Fixture.time(10, 30))
        let yesterday = [Fixture.night(endingAt: Fixture.time(22, day: 30))]
        #expect(advisor.wakeTime(from: yesterday, on: Fixture.time(9)) == nil)
    }

    @Test func daysAreClassifiedByWorkWeekAndHolidays() {
        let classifier = FlexTimeDayClassifier(
            workdays: Calendar.fallbackWorkdays,
            holidays: [Fixture.day, HolidayDay(year: 2026, month: 11, day: 3)]
        )
        #expect(classifier.kinds(of: Fixture.time(9), calendar: Fixtures.calendar) == [.weekend, .publicHoliday])
        #expect(classifier.kinds(of: Fixture.time(9, day: 30), calendar: Fixtures.calendar) == [.weekday])
        #expect(classifier.kinds(of: Fixtures.date(2026, 11, 3), calendar: Fixtures.calendar) == [.publicHoliday])
        #expect(classifier.kinds(of: Fixtures.date(2026, 11, 1), calendar: Fixtures.calendar) == [.weekend])
    }
}
