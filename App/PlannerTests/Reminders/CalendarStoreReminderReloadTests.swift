import Foundation
import Observation
import Synchronization
import Testing
@testable import Planner

@MainActor
struct CalendarStoreReminderReloadTests {
    private let today = DateInterval(start: Fixtures.date(2026, 10, 29), end: Fixtures.date(2026, 10, 30))

    private func makeStore(source: FakeCalendarDataSource) async throws -> CalendarStore {
        let defaults = try #require(UserDefaults(suiteName: "ReminderReloadTests.\(UUID().uuidString)"))
        return await CalendarStore(
            source: source,
            policy: CacheWindowPolicy(paddingWeeks: 1, calendar: Fixtures.calendar),
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults),
            reminderSettings: ReminderSettings(defaults: defaults),
            now: { Fixtures.date(2026, 10, 29, hour: 12) }
        ).loaded()
    }

    @Test func completingAReminderRefetchesRemindersButNotEvents() async throws {
        let milk = Fixtures.reminder(local: "milk", due: Fixtures.date(2026, 10, 29, hour: 12))
        let source = FakeCalendarDataSource(
            events: [Fixtures.event(local: "standup", start: Fixtures.date(2026, 10, 29, hour: 9))],
            reminders: [milk],
            calendars: [Fixtures.plannerCalendar("list-1", kind: .reminder)]
        )
        let store = try await makeStore(source: source)
        _ = await store.events(in: today)
        _ = await store.reminders(in: today)
        let eventFetches = source.eventFetchIntervals.count
        let reminderFetches = source.incompleteReminderFetchCount

        try await store.setCompleted(true, for: milk)

        #expect(store.contentRevision == 1)
        #expect(source.eventFetchIntervals.count == eventFetches)
        #expect(source.incompleteReminderFetchCount == reminderFetches + 1)
        _ = await store.events(in: today)
        #expect(source.eventFetchIntervals.count == eventFetches)
    }

    @Test func anUnchangedReloadDoesNotRepublishReminderLists() async throws {
        let source = FakeCalendarDataSource(calendars: [Fixtures.plannerCalendar("list-1", kind: .reminder)])
        let store = try await makeStore(source: source)
        let republished = Mutex(false)
        withObservationTracking {
            _ = store.reminderLists
            _ = store.eventCalendars
        } onChange: {
            republished.withLock { $0 = true }
        }

        await store.handleExternalChange()

        #expect(store.reminderLists.map(\.id) == ["list-1"])
        #expect(!republished.withLock { $0 })
    }
}
