import Foundation
import Testing
@testable import Planner

@MainActor
struct CalendarStoreNoteLinkTests {
    private let link = URL(string: "folio://note/Standup%202026-10-29.md")

    private func makeStore(_ source: FakeCalendarDataSource) throws -> CalendarStore {
        let defaults = try #require(UserDefaults(suiteName: "CalendarStoreNoteLinkTests.\(UUID().uuidString)"))
        return CalendarStore(
            source: source,
            policy: CacheWindowPolicy(paddingWeeks: 1, calendar: Fixtures.calendar),
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults)
        )
    }

    private func createEvent(in store: CalendarStore, url: URL? = nil) async throws -> CalendarEvent {
        let start = Fixtures.date(2026, 10, 29, hour: 9)
        let reference = try await store.createEvent(EventDraft(
            title: "Standup", calendarIdentifier: "work",
            startDate: start, endDate: start.addingTimeInterval(900), url: url
        ))
        return try #require(await store.event(matching: reference, near: start, calendar: Fixtures.calendar))
    }

    @Test func writesTheLinkIntoAnEmptyURLField() async throws {
        let source = FakeCalendarDataSource(calendars: [Fixtures.plannerCalendar("work")])
        let store = try makeStore(source)
        let event = try await createEvent(in: store)
        let link = try #require(link)

        #expect(try await store.addNoteLink(link, to: event))
        #expect(source.currentEvents.first?.url == link)
    }

    @Test func keepsAnExistingURL() async throws {
        let source = FakeCalendarDataSource(calendars: [Fixtures.plannerCalendar("work")])
        let store = try makeStore(source)
        let existing = try #require(URL(string: "https://example.com"))
        let event = try await createEvent(in: store, url: existing)

        #expect(try await store.addNoteLink(try #require(link), to: event) == false)
        #expect(source.currentEvents.first?.url == existing)
    }
}
