import Foundation
import Testing
@testable import Planner

@MainActor
struct CalendarStoreTests {
    private let today = DateInterval(start: Fixtures.date(2026, 10, 29), end: Fixtures.date(2026, 10, 30))

    private func makeStore(source: FakeCalendarDataSource, defaults: UserDefaults) -> CalendarStore {
        CalendarStore(
            source: source,
            policy: CacheWindowPolicy(paddingWeeks: 1, calendar: Fixtures.calendar),
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults)
        )
    }

    private func makeDefaults() throws -> UserDefaults {
        let suiteName = "CalendarStoreTests.\(UUID().uuidString)"
        return try #require(UserDefaults(suiteName: suiteName))
    }

    @Test func hiddenCalendarsAreFilteredAndPersisted() async throws {
        let work = Fixtures.plannerCalendar("work")
        let source = FakeCalendarDataSource(
            events: [
                Fixtures.event(local: "meeting", calendarIdentifier: "work", start: Fixtures.date(2026, 10, 29, hour: 9)),
                Fixtures.event(local: "gym", calendarIdentifier: "home", start: Fixtures.date(2026, 10, 29, hour: 18))
            ],
            calendars: [work, Fixtures.plannerCalendar("home")]
        )
        let defaults = try makeDefaults()
        let store = makeStore(source: source, defaults: defaults)
        #expect(store.eventCalendars.map(\.id) == ["home", "work"])

        store.setVisible(false, for: work)
        #expect(!store.isVisible(work))
        #expect(await store.events(in: today).map(\.title) == ["gym"])
        #expect(makeStore(source: source, defaults: defaults).hiddenCalendarIdentifiers == ["work"])

        store.setVisible(true, for: work)
        #expect(await store.events(in: today).count == 2)
    }

    @Test func externalChangeRefetchesVisibleRangeAndBumpsRevision() async throws {
        let source = FakeCalendarDataSource(events: [
            Fixtures.event(local: "old", start: Fixtures.date(2026, 10, 29, hour: 9))
        ])
        let store = makeStore(source: source, defaults: try makeDefaults())
        store.startObservingChanges()
        defer { store.stopObservingChanges() }
        _ = await store.events(in: today)

        source.replaceEvents([Fixtures.event(local: "new", start: Fixtures.date(2026, 10, 29, hour: 9))])
        source.postChange()
        while store.contentRevision == 0 {
            await Task.yield()
        }
        #expect(source.eventFetchIntervals.count == 2)
        #expect(await store.events(in: today).map(\.title) == ["new"])
    }

    @Test func completingReminderWritesThroughSource() async throws {
        let reminder = Fixtures.reminder(local: "milk", due: Fixtures.date(2026, 10, 29, hour: 12))
        let source = FakeCalendarDataSource(reminders: [reminder])
        let store = makeStore(source: source, defaults: try makeDefaults())
        try await store.setCompleted(true, for: reminder)
        #expect(source.completedReminderIdentifiers == ["milk": true])
        #expect(store.contentRevision == 1)
    }
}
