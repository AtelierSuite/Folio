import Foundation
import Testing
@testable import Planner

@MainActor
struct CalendarStoreDuplicatesTests {
    private let start = Fixtures.date(2026, 11, 4, hour: 9)

    private func copy(_ local: String, calendarIdentifier: String) -> CalendarEvent {
        CalendarEvent(
            reference: Fixtures.reference(
                external: "external-\(local)", local: local, calendarIdentifier: calendarIdentifier
            ),
            calendarIdentifier: calendarIdentifier,
            title: "Team Sync",
            startDate: start,
            endDate: start.addingTimeInterval(3600)
        )
    }

    private func makeStore(events: [CalendarEvent], hidden: Set<String> = []) throws -> CalendarStore {
        let defaults = try #require(UserDefaults(suiteName: "CalendarStoreDuplicatesTests.\(UUID().uuidString)"))
        let storage = CalendarVisibilityStorage(defaults: defaults)
        storage.hiddenCalendarIdentifiers = hidden
        return CalendarStore(
            source: FakeCalendarDataSource(events: events),
            policy: CacheWindowPolicy(paddingWeeks: 1, calendar: Fixtures.calendar),
            visibilityStorage: storage
        )
    }

    @Test func listsTheOtherCopiesWhicheverCopyIsAsked() async throws {
        let work = copy("first", calendarIdentifier: "work")
        let home = copy("second", calendarIdentifier: "home")
        let store = try makeStore(events: [work, home])
        #expect(await store.duplicates(of: work, calendar: Fixtures.calendar) == [home])
        #expect(await store.duplicates(of: home, calendar: Fixtures.calendar) == [work])
    }

    @Test func copiesOnHiddenCalendarsAreLeftOut() async throws {
        let work = copy("first", calendarIdentifier: "work")
        let store = try makeStore(events: [work, copy("second", calendarIdentifier: "home")], hidden: ["home"])
        #expect(await store.duplicates(of: work, calendar: Fixtures.calendar).isEmpty)
    }
}
