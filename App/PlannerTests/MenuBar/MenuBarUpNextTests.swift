import Foundation
import Testing
@testable import Planner

struct MenuBarUpNextTests {
    private let now = Fixtures.date(2026, 11, 10, hour: 9)

    @Test func picksTheNextEventThatHasNotStarted() throws {
        let events = [
            Fixtures.event(local: "ongoing", start: now.addingTimeInterval(-600)),
            Fixtures.event(local: "later", start: now.addingTimeInterval(7_200)),
            Fixtures.event(local: "next", start: now.addingTimeInterval(1_500))
        ]
        let upNext = try #require(MenuBarUpNext(events: events, at: now))
        #expect(upNext.event.title == "next")
        #expect(upNext.minutesUntilStart == 25)
    }

    @Test func skipsAllDayEventsAndEventsPastTheLookahead() {
        let allDay = CalendarEvent(
            reference: Fixtures.reference(external: nil, local: "holiday"),
            calendarIdentifier: "calendar-1",
            title: "holiday",
            startDate: now.addingTimeInterval(3_600),
            endDate: now.addingTimeInterval(90_000),
            isAllDay: true
        )
        let tooFar = Fixtures.event(local: "next week", start: now.addingTimeInterval(MenuBarUpNext.lookahead + 60))
        #expect(MenuBarUpNext(events: [allDay, tooFar], at: now) == nil)
    }

    @Test func roundsTheCountdownUpToTheMinute() throws {
        let events = [Fixtures.event(local: "soon", start: now.addingTimeInterval(30))]
        #expect(try #require(MenuBarUpNext(events: events, at: now)).minutesUntilStart == 1)
    }
}
