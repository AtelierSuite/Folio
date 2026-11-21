import Foundation
import Testing
@testable import Planner

@MainActor
struct CalendarStoreChangeNoticeTests {
    private let today = DateInterval(start: Fixtures.date(2026, 10, 29), end: Fixtures.date(2026, 10, 30))

    private func makeStore(source: FakeCalendarDataSource) throws -> CalendarStore {
        let defaults = try #require(UserDefaults(suiteName: "CalendarStoreChangeNoticeTests.\(UUID().uuidString)"))
        return CalendarStore(
            source: source,
            policy: CacheWindowPolicy(paddingWeeks: 1, calendar: Fixtures.calendar),
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults)
        )
    }

    private func waitForRevision(_ revision: Int, of store: CalendarStore) async throws {
        let deadline = ContinuousClock.now + .seconds(5)
        while store.contentRevision < revision {
            try #require(ContinuousClock.now < deadline)
            try await Task.sleep(for: .milliseconds(10))
        }
    }

    @Test func aBurstOfStoreChangesReloadsOnce() async throws {
        let standup = Fixtures.event(local: "standup", start: Fixtures.date(2026, 10, 29, hour: 9))
        let source = FakeCalendarDataSource(events: [standup])
        let store = try makeStore(source: source)
        store.startObservingChanges()
        defer { store.stopObservingChanges() }
        _ = await store.events(in: today)
        for _ in 0..<3 {
            source.postChange()
            try await Task.sleep(for: .milliseconds(20))
        }
        try await waitForRevision(1, of: store)
        try await Task.sleep(for: CalendarStore.storeChangeDebounce * 2)
        #expect(store.contentRevision == 1)
        #expect(source.eventFetchIntervals.count == 2)
    }

    @Test func theStoreChangeFromFolioItsOwnWriteIsSkipped() async throws {
        let reminder = Fixtures.reminder(local: "milk", due: Fixtures.date(2026, 10, 29, hour: 12))
        let source = FakeCalendarDataSource(reminders: [reminder])
        let store = try makeStore(source: source)
        store.startObservingChanges()
        defer { store.stopObservingChanges() }
        _ = await store.events(in: today)
        try await store.setCompleted(true, for: reminder)
        #expect(store.contentRevision == 1)
        source.postChange()
        try await Task.sleep(for: CalendarStore.storeChangeDebounce * 2)
        #expect(store.contentRevision == 1)
        source.postChange()
        try await waitForRevision(2, of: store)
    }
}
