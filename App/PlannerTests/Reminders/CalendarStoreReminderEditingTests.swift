import Foundation
import Testing
@testable import Planner

@MainActor
struct CalendarStoreReminderEditingTests {
    private let today = DateInterval(start: Fixtures.date(2026, 10, 29), end: Fixtures.date(2026, 10, 30))
    private let readOnlyList = PlannerCalendar(
        id: "shared",
        title: "Shared",
        kind: .reminder,
        color: .gray,
        sourceIdentifier: "source",
        sourceTitle: "iCloud",
        sourceType: .calDAV,
        isReadOnly: true
    )

    private func makeStore(source: FakeCalendarDataSource) throws -> CalendarStore {
        let defaults = try #require(UserDefaults(suiteName: "ReminderEditingTests.\(UUID().uuidString)"))
        return CalendarStore(
            source: source,
            policy: CacheWindowPolicy(paddingWeeks: 1, calendar: Fixtures.calendar),
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults),
            reminderSettings: ReminderSettings(defaults: defaults),
            now: { Fixtures.date(2026, 10, 29, hour: 12) }
        )
    }

    private func makeSource(reminders: [ReminderItem] = []) -> FakeCalendarDataSource {
        FakeCalendarDataSource(
            reminders: reminders,
            calendars: [readOnlyList, Fixtures.plannerCalendar("list-1", kind: .reminder)]
        )
    }

    @Test func newDraftUsesFirstWritableList() throws {
        let store = try makeStore(source: makeSource())
        #expect(store.writableReminderLists.map(\.id) == ["list-1"])
        let draft = store.newReminderDraft(dueOn: today.start)
        #expect(draft.listIdentifier == "list-1")
        #expect(draft.dueDate == today.start)
        #expect(!draft.hasDueTime)
    }

    @Test func createdReminderAppearsAfterReload() async throws {
        let source = makeSource()
        let store = try makeStore(source: source)
        _ = await store.reminders(in: today)
        let draft = ReminderDraft(
            title: " Buy milk ",
            listIdentifier: "list-1",
            dueDate: Fixtures.date(2026, 10, 29, hour: 17),
            hasDueTime: true,
            priority: .high,
            alarms: [.relative(-900)]
        )
        let identifier = try await store.createReminder(draft)
        let created = try #require(await store.reminders(in: today).first)
        #expect(created.id == identifier)
        #expect(created.title == "Buy milk")
        #expect(created.priority == ReminderPriority.high.rawValue)
        #expect(created.alarms == [.relative(-900)])
        #expect(store.contentRevision == 1)
    }

    @Test func updateWritesNormalizedDraft() async throws {
        let reminder = Fixtures.reminder(local: "milk", due: Fixtures.date(2026, 10, 29, hour: 12))
        let source = makeSource(reminders: [reminder])
        let store = try makeStore(source: source)
        var draft = ReminderDraft(reminder)
        draft.title = "Oat milk"
        draft.dueDate = nil
        draft.recurrence = ReminderRecurrence(frequency: .weekly)
        draft.url = URL(string: "https://example.com")
        try await store.updateReminder(reminder, with: draft)
        let updated = try #require(source.storedReminders.first)
        #expect(updated.title == "Oat milk")
        #expect(updated.dueDate == nil)
        #expect(updated.recurrence == nil)
        #expect(updated.url == URL(string: "https://example.com"))
    }

    @Test func deleteRemovesReminder() async throws {
        let reminder = Fixtures.reminder(local: "milk", due: Fixtures.date(2026, 10, 29, hour: 12))
        let source = makeSource(reminders: [reminder])
        let store = try makeStore(source: source)
        try await store.deleteReminder(reminder)
        #expect(source.storedReminders.isEmpty)
        #expect(await store.reminders(in: today).isEmpty)
    }

    @Test func readOnlyRemindersAndListsAreRejected() async throws {
        let readOnly = ReminderItem(
            reference: Fixtures.reference(local: "shared-item", calendarIdentifier: "shared"),
            listIdentifier: "shared",
            title: "Shared",
            isReadOnly: true
        )
        let source = makeSource(reminders: [readOnly])
        let store = try makeStore(source: source)
        await #expect(throws: ReminderEditingError.readOnly) {
            try await store.updateReminder(readOnly, with: ReminderDraft(title: "New", listIdentifier: "list-1"))
        }
        await #expect(throws: ReminderEditingError.readOnly) {
            try await store.deleteReminder(readOnly)
        }
        await #expect(throws: ReminderEditingError.readOnly) {
            try await store.createReminder(ReminderDraft(title: "New", listIdentifier: "shared"))
        }
        #expect(source.storedReminders == [readOnly])
    }

    @Test func invalidDraftsAreRejected() async throws {
        let store = try makeStore(source: makeSource())
        await #expect(throws: ReminderEditingError.invalidDraft) {
            try await store.createReminder(ReminderDraft(title: " ", listIdentifier: "list-1"))
        }
        await #expect(throws: ReminderEditingError.listNotFound) {
            try await store.createReminder(ReminderDraft(title: "Milk", listIdentifier: "missing"))
        }
    }
}
