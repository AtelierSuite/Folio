import Foundation
import Testing
@testable import Planner

@MainActor
struct CalendarStoreReminderScheduleTests {
    private let today = DateInterval(start: Fixtures.date(2026, 10, 29), end: Fixtures.date(2026, 10, 30))

    private func makeDefaults() throws -> UserDefaults {
        try #require(UserDefaults(suiteName: "ReminderScheduleTests.\(UUID().uuidString)"))
    }

    private func makeStore(source: FakeCalendarDataSource, defaults: UserDefaults) -> CalendarStore {
        CalendarStore(
            source: source,
            policy: CacheWindowPolicy(paddingWeeks: 1, calendar: Fixtures.calendar),
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults),
            reminderSettings: ReminderSettings(defaults: defaults),
            now: { Fixtures.date(2026, 10, 29, hour: 12) }
        )
    }

    private func makeSource() -> FakeCalendarDataSource {
        FakeCalendarDataSource(
            reminders: [
                Fixtures.reminder(local: "overdue", due: Fixtures.date(2026, 10, 26)),
                Fixtures.reminder(local: "today", due: Fixtures.date(2026, 10, 29, hour: 9)),
                Fixtures.reminder(local: "undated", due: nil),
                Fixtures.reminder(local: "hidden undated", listIdentifier: "hidden", due: nil)
            ],
            calendars: [
                Fixtures.plannerCalendar("list-1", kind: .reminder),
                Fixtures.plannerCalendar("hidden", kind: .reminder)
            ]
        )
    }

    @Test func carriesOverdueRemindersForwardByDefault() async throws {
        let store = makeStore(source: makeSource(), defaults: try makeDefaults())
        #expect(store.overdueReminderPolicy == .carryForward)
        let titles = await store.reminders(in: today, calendar: Fixtures.calendar).map(\.title)
        #expect(titles == ["overdue", "today"])
    }

    @Test func changingPolicyPersistsAndRefreshes() async throws {
        let defaults = try makeDefaults()
        let source = makeSource()
        let store = makeStore(source: source, defaults: defaults)
        store.setOverdueReminderPolicy(.keepOnDueDate)
        #expect(store.contentRevision == 1)
        #expect(await store.reminders(in: today, calendar: Fixtures.calendar).map(\.title) == ["today"])
        #expect(makeStore(source: source, defaults: defaults).overdueReminderPolicy == .keepOnDueDate)
    }

    @Test func undatedRemindersSkipHiddenLists() async throws {
        let store = makeStore(source: makeSource(), defaults: try makeDefaults())
        #expect(await store.undatedReminders(calendar: Fixtures.calendar).map(\.title) == ["hidden undated", "undated"])
        let hidden = try #require(store.reminderLists.first { $0.id == "hidden" })
        store.setVisible(false, for: hidden)
        #expect(await store.undatedReminders(calendar: Fixtures.calendar).map(\.title) == ["undated"])
    }
}
