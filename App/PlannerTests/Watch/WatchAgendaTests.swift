import Foundation
import Testing
@testable import Planner

struct WatchAgendaTests {
    private let now = Fixtures.date(2026, 11, 9, hour: 12)

    @Test func dropsEventsThatHaveEnded() {
        let events = [
            Fixtures.event(local: "morning", start: Fixtures.date(2026, 11, 9, hour: 9)),
            Fixtures.event(local: "lunch", start: Fixtures.date(2026, 11, 9, hour: 11), hours: 2),
            Fixtures.event(local: "evening", start: Fixtures.date(2026, 11, 9, hour: 18))
        ]
        let agenda = WatchAgenda(events: events, from: now, calendar: Fixtures.calendar)
        #expect(agenda.days.first?.timedEvents.map(\.title) == ["lunch", "evening"])
    }

    @Test func keepsTodayEvenWhenItIsEmptyAndSkipsOtherEmptyDays() {
        let events = [Fixtures.event(local: "later", start: Fixtures.date(2026, 11, 12, hour: 10))]
        let agenda = WatchAgenda(events: events, from: now, calendar: Fixtures.calendar)
        #expect(agenda.days.map(\.date) == [Fixtures.date(2026, 11, 9), Fixtures.date(2026, 11, 12)])
        #expect(agenda.days.first?.isEmpty == true)
        #expect(!agenda.isEmpty)
    }

    @Test func showsMultiDayEventsOnEveryDayTheyCover() {
        let trip = CalendarEvent(
            reference: Fixtures.reference(local: "trip"),
            calendarIdentifier: "calendar-1",
            title: "trip",
            startDate: Fixtures.date(2026, 11, 9),
            endDate: Fixtures.date(2026, 11, 11),
            isAllDay: true
        )
        let agenda = WatchAgenda(events: [trip], from: now, calendar: Fixtures.calendar)
        #expect(agenda.days.map(\.date) == [Fixtures.date(2026, 11, 9), Fixtures.date(2026, 11, 10)])
        #expect(agenda.days.allSatisfy { $0.allDayEvents.map(\.title) == ["trip"] })
    }

    @Test func stopsAfterTheDayCount() {
        let events = [Fixtures.event(local: "far", start: Fixtures.date(2026, 11, 20, hour: 10))]
        let agenda = WatchAgenda(events: events, from: now, dayCount: 3, calendar: Fixtures.calendar)
        #expect(agenda.days.count == 1)
        #expect(agenda.isEmpty)
    }
}
