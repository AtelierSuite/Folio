import Foundation
import Testing
@testable import Planner

struct CalendarRepositoryWindowTests {
    private let policy = CacheWindowPolicy(paddingWeeks: 1, calendar: Fixtures.calendar)
    private let today = DateInterval(start: Fixtures.date(2026, 10, 29), end: Fixtures.date(2026, 10, 30))
    private let twoMonthsAhead = DateInterval(start: Fixtures.date(2026, 12, 29), end: Fixtures.date(2026, 12, 30))

    @Test func keepsSeveralWindowsSoAlternatingRangesDontRefetch() async {
        let source = FakeCalendarDataSource(events: [
            Fixtures.event(local: "now", start: Fixtures.date(2026, 10, 29, hour: 9)),
            Fixtures.event(local: "later", start: Fixtures.date(2026, 12, 29, hour: 9))
        ])
        let repository = CalendarRepository(source: source, policy: policy)
        for _ in 0..<3 {
            #expect(await repository.events(in: twoMonthsAhead).map(\.title) == ["later"])
            #expect(await repository.events(in: today).map(\.title) == ["now"])
        }
        #expect(source.eventFetchIntervals == [policy.window(around: twoMonthsAhead), policy.window(around: today)])
    }

    @Test func dropsTheLeastRecentlyUsedWindowPastCapacity() async {
        let source = FakeCalendarDataSource()
        let repository = CalendarRepository(source: source, policy: policy)
        let months = (1...CalendarRepository.windowCapacity + 1).map { month in
            DateInterval(start: Fixtures.date(2026, month, 1), end: Fixtures.date(2026, month, 2))
        }
        for month in months {
            _ = await repository.events(in: month)
        }
        _ = await repository.events(in: months[1])
        #expect(source.eventFetchIntervals.count == months.count)
        _ = await repository.events(in: months[0])
        #expect(source.eventFetchIntervals.count == months.count + 1)
        #expect(await repository.cachedEventIntervals.count == CalendarRepository.windowCapacity)
    }

    @Test func concurrentMissesShareOneFetch() async {
        let source = FakeCalendarDataSource(
            events: [Fixtures.event(local: "standup", start: Fixtures.date(2026, 10, 29, hour: 9))],
            reminders: [Fixtures.reminder(local: "milk", due: nil)]
        )
        source.setFetchDelay(.milliseconds(200))
        let repository = CalendarRepository(source: source, policy: policy)
        async let first = repository.events(in: today)
        async let second = repository.events(in: today)
        async let firstReminders = repository.reminders(around: today)
        async let secondReminders = repository.reminders(around: today)
        let results = await (first, second, firstReminders, secondReminders)
        #expect(results.0.map(\.title) == ["standup"])
        #expect(results.1.map(\.title) == ["standup"])
        #expect(results.2.map(\.title) == ["milk"])
        #expect(results.3.map(\.title) == ["milk"])
        #expect(source.eventFetchIntervals.count == 1)
        #expect(source.incompleteReminderFetchCount == 1)
        #expect(source.completedReminderFetchIntervals.count == 1)
    }

    @Test func fetchesIncompleteRemindersOnceAcrossWindows() async {
        let source = FakeCalendarDataSource(reminders: [Fixtures.reminder(local: "milk", due: nil)])
        let repository = CalendarRepository(source: source, policy: policy)
        _ = await repository.reminders(around: today)
        _ = await repository.reminders(around: twoMonthsAhead)
        _ = await repository.reminders(around: today)
        #expect(source.incompleteReminderFetchCount == 1)
        #expect(source.completedReminderFetchIntervals == [
            policy.window(around: today), policy.window(around: twoMonthsAhead)
        ])
    }

    @Test func aFetchStartedBeforeInvalidationIsNotCached() async {
        let source = FakeCalendarDataSource(events: [
            Fixtures.event(local: "old", start: Fixtures.date(2026, 10, 29, hour: 9))
        ])
        source.setFetchDelay(.milliseconds(200))
        let repository = CalendarRepository(source: source, policy: policy)
        async let stale = repository.events(in: today)
        try? await Task.sleep(for: .milliseconds(50))
        source.replaceEvents([Fixtures.event(local: "new", start: Fixtures.date(2026, 10, 29, hour: 9))])
        await repository.invalidate()
        _ = await stale
        #expect(await repository.events(in: today).map(\.title) == ["new"])
    }
}
