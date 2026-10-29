import Foundation
import Testing
@testable import Planner

struct EventLookupTests {
    private let now = IntentTestSupport.now

    private func lookup(_ events: [CalendarEvent], hiding hidden: Set<String> = []) throws -> EventLookup {
        EventLookup(
            source: FakeCalendarDataSource(events: events),
            visibilityStorage: try IntentTestSupport.visibilityStorage(hiding: hidden),
            calendar: Fixtures.calendar
        )
    }

    @Test func findsAnEventByItsStorageKey() async throws {
        let dentist = IntentTestSupport.event("Dentist", start: Fixtures.date(2026, 11, 20, hour: 15))
        let lookup = try lookup([IntentTestSupport.event("Standup", start: now), dentist])

        let found = await lookup.events(withIdentifiers: [dentist.reference.storageKey], now: now)

        #expect(found == [dentist])
        #expect(EventEntity(dentist).id == dentist.reference.storageKey)
    }

    @Test func findsTheRightOccurrenceOfARecurringEvent() async throws {
        let occurrences = (29...31).map { day in
            let start = Fixtures.date(2026, 10, day, hour: 9)
            return IntentTestSupport.event("Standup", start: start, occurrence: start)
        }
        let lookup = try lookup(occurrences)

        let found = await lookup.events(withIdentifiers: [occurrences[1].reference.storageKey], now: now)

        #expect(found == [occurrences[1]])
    }

    @Test func matchesWhatSiriHeardWordByWord() async throws {
        let dentist = IntentTestSupport.event("Dentist", start: Fixtures.date(2026, 11, 2, hour: 15))
        let dentistAppointment = IntentTestSupport.event(
            "Dentist appointment", start: Fixtures.date(2026, 11, 20, hour: 15)
        )
        let lunch = IntentTestSupport.event("Lunch", start: Fixtures.date(2026, 10, 30, hour: 12))
        let lookup = try lookup([dentist, dentistAppointment, lunch])

        #expect(await lookup.events(matching: "dentist appointment", now: now) == [dentistAppointment])
        #expect(await lookup.events(matching: "Dentist", now: now) == [dentist, dentistAppointment])
        #expect(await lookup.events(matching: "dinner", now: now).isEmpty)
    }

    @Test func matchesLocationsAndPrefersUpcomingEvents() async throws {
        let past = IntentTestSupport.event("Yoga", start: Fixtures.date(2026, 10, 20, hour: 8), location: "Gym")
        let upcoming = IntentTestSupport.event("Spin", start: Fixtures.date(2026, 11, 3, hour: 8), location: "Gym")
        let lookup = try lookup([past, upcoming])

        #expect(await lookup.events(matching: "gym", now: now) == [upcoming, past])
    }

    @Test func suggestsUpcomingVisibleEventsInOrder() async throws {
        let finished = IntentTestSupport.event("Breakfast", start: Fixtures.date(2026, 10, 29, hour: 7))
        let ongoing = IntentTestSupport.event("Standup", start: Fixtures.date(2026, 10, 29, hour: 9), hours: 2)
        let later = IntentTestSupport.event("Review", start: Fixtures.date(2026, 10, 30, hour: 9))
        let hidden = IntentTestSupport.event(
            "Birthday", start: Fixtures.date(2026, 10, 29, hour: 12), calendarIdentifier: "hidden"
        )
        let lookup = try lookup([later, hidden, finished, ongoing], hiding: ["hidden"])

        #expect(await lookup.upcomingEvents(now: now) == [ongoing, later])
    }
}
