import Foundation
import Testing
@testable import Planner

struct CalendarRepositoryTests {
    private let policy = CacheWindowPolicy(paddingWeeks: 1, calendar: Fixtures.calendar)
    private let today = DateInterval(start: Fixtures.date(2026, 10, 29), end: Fixtures.date(2026, 10, 30))
    private let tomorrow = DateInterval(start: Fixtures.date(2026, 10, 30), end: Fixtures.date(2026, 10, 31))

    @Test func servesRangesInsideWindowFromCache() async {
        let source = FakeCalendarDataSource(events: [
            Fixtures.event(local: "today", start: Fixtures.date(2026, 10, 29, hour: 9)),
            Fixtures.event(local: "tomorrow", start: Fixtures.date(2026, 10, 30, hour: 9))
        ])
        let repository = CalendarRepository(source: source, policy: policy)
        #expect(await repository.events(in: today).map(\.title) == ["today"])
        #expect(await repository.events(in: tomorrow).map(\.title) == ["tomorrow"])
        #expect(source.eventFetchIntervals == [policy.window(around: today)])
    }

    @Test func refetchesOutsideWindow() async {
        let source = FakeCalendarDataSource()
        let repository = CalendarRepository(source: source, policy: policy)
        let nextMonth = DateInterval(start: Fixtures.date(2026, 11, 29), end: Fixtures.date(2026, 11, 30))
        _ = await repository.events(in: today)
        _ = await repository.events(in: nextMonth)
        #expect(source.eventFetchIntervals.count == 2)
    }

    @Test func reloadRefetchesVisibleRange() async {
        let source = FakeCalendarDataSource(events: [
            Fixtures.event(local: "old", start: Fixtures.date(2026, 10, 29, hour: 9))
        ])
        let repository = CalendarRepository(source: source, policy: policy)
        _ = await repository.events(in: today)
        source.replaceEvents([Fixtures.event(local: "new", start: Fixtures.date(2026, 10, 29, hour: 10))])
        await repository.reload(visible: today)
        #expect(await repository.events(in: today).map(\.title) == ["new"])
        #expect(source.eventFetchIntervals.count == 2)
    }

    @Test func cachesRemindersAndFiltersByDueDate() async {
        let source = FakeCalendarDataSource(reminders: [
            Fixtures.reminder(local: "today", due: Fixtures.date(2026, 10, 29, hour: 12)),
            Fixtures.reminder(local: "undated", due: nil)
        ])
        let repository = CalendarRepository(source: source, policy: policy)
        #expect(await repository.reminders(in: today).map(\.title) == ["today"])
        #expect(await repository.reminders(in: tomorrow).isEmpty)
        #expect(source.reminderFetchCount == 1)
    }
}
