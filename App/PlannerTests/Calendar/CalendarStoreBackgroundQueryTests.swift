import Foundation
import Testing
@testable import Planner

@MainActor
struct CalendarStoreBackgroundQueryTests {
    private let policy = CacheWindowPolicy(paddingWeeks: 1, calendar: Fixtures.calendar)
    private let page = DateInterval(start: Fixtures.date(2026, 12, 28), end: Fixtures.date(2027, 1, 4))
    private let digest = DateInterval(start: Fixtures.date(2026, 10, 29, hour: 8), duration: 7 * 86_400)

    private func makeStore(source: FakeCalendarDataSource) throws -> CalendarStore {
        let defaults = try #require(UserDefaults(suiteName: "CalendarStoreBackgroundQueryTests.\(UUID().uuidString)"))
        return CalendarStore(
            source: source,
            policy: policy,
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults),
            now: { Fixtures.date(2026, 10, 29, hour: 12) }
        )
    }

    @Test func aDigestRequestDoesNotEvictThePageAheadOfIt() async throws {
        let source = FakeCalendarDataSource(events: [
            Fixtures.event(local: "soon", start: Fixtures.date(2026, 10, 30, hour: 9)),
            Fixtures.event(local: "later", start: Fixtures.date(2026, 12, 29, hour: 9))
        ])
        let store = try makeStore(source: source)
        #expect(await store.events(in: page).map(\.title) == ["later"])
        for _ in 0..<3 {
            #expect(await store.backgroundEvents(in: digest).map(\.title) == ["soon"])
            #expect(await store.events(in: page).map(\.title) == ["later"])
        }
        #expect(source.eventFetchIntervals == [policy.window(around: page), policy.window(around: digest)])
        #expect(store.visibleInterval == page)
    }

    @Test func anExternalChangeRefreshesThePageAfterABackgroundRequest() async throws {
        let source = FakeCalendarDataSource(events: [
            Fixtures.event(local: "old", start: Fixtures.date(2026, 12, 29, hour: 9))
        ])
        let store = try makeStore(source: source)
        store.startObservingChanges()
        defer { store.stopObservingChanges() }
        _ = await store.events(in: page)
        _ = await store.backgroundEvents(in: digest)
        source.replaceEvents([Fixtures.event(local: "new", start: Fixtures.date(2026, 12, 29, hour: 9))])
        source.postChange()
        let deadline = ContinuousClock.now + .seconds(5)
        while store.contentRevision == 0 {
            try #require(ContinuousClock.now < deadline)
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(source.eventFetchIntervals.last == policy.window(around: page))
        let fetchCount = source.eventFetchIntervals.count
        #expect(await store.events(in: page).map(\.title) == ["new"])
        #expect(source.eventFetchIntervals.count == fetchCount)
    }

    @Test func aReminderCompletedWhileAPageIsAheadStaysInItsList() async throws {
        let open = Fixtures.reminder(local: "milk", due: Fixtures.date(2026, 12, 29, hour: 12))
        let source = FakeCalendarDataSource(reminders: [open])
        let store = try makeStore(source: source)
        _ = await store.reminders(in: page, calendar: Fixtures.calendar)
        #expect(await store.reminders(inList: "list-1", calendar: Fixtures.calendar).map(\.isCompleted) == [false])
        source.replaceReminders([ReminderItem(
            reference: open.reference,
            listIdentifier: open.listIdentifier,
            title: open.title,
            dueDate: open.dueDate,
            isCompleted: true,
            completionDate: Fixtures.date(2026, 10, 29, hour: 12)
        )])
        try await store.setCompleted(true, for: open)
        #expect(await store.reminders(inList: "list-1", calendar: Fixtures.calendar).map(\.isCompleted) == [true])
        #expect(await store.openReminderCounts(calendar: Fixtures.calendar).isEmpty)
    }
}
