import EventKit
import Foundation
import Testing
@testable import Planner

/// Runs against the real event store and skips without reminders access. Run it hosted in the app
/// after granting the app reminders access, as described in `EventKitEventWritingTests`.
@MainActor
@Suite(.serialized, .enabled(if: EKEventStore.authorizationStatus(for: .reminder) == .fullAccess))
struct EventKitRecurringReminderCompletionTests {
    private let source = EventKitDataSource.shared
    private let calendar = Calendar.current

    private func withTemporaryList(_ body: (CalendarStore, EKCalendar) async throws -> Void) async throws {
        let eventStore = source.eventStore
        let list = EKCalendar(for: .reminder, eventStore: eventStore)
        list.title = "Folio Tests \(UUID().uuidString)"
        list.source = try #require(
            eventStore.defaultCalendarForNewReminders()?.source ?? eventStore.sources.first { $0.sourceType == .local }
        )
        try eventStore.saveCalendar(list, commit: true)
        defer { try? eventStore.removeCalendar(list, commit: true) }
        let defaults = try #require(UserDefaults(suiteName: "RecurringReminderTests.\(UUID().uuidString)"))
        let store = CalendarStore(
            source: source,
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults),
            reminderSettings: ReminderSettings(defaults: defaults)
        )
        try await body(store, list)
    }

    private func reminders(in store: CalendarStore, list: EKCalendar, from start: Date) async -> [ReminderItem] {
        let interval = DateInterval(start: start, duration: 3 * 86400)
        return await store.reminders(in: interval).filter { $0.listIdentifier == list.calendarIdentifier }
    }

    /// Like Reminders.app, completing a repeating reminder keeps the series open on its next due date
    /// and leaves a separate, completed copy behind on the day that was checked off.
    @Test func completingRecurringReminderAdvancesItAndKeepsACompletedCopy() async throws {
        try await withTemporaryList { store, list in
            let today = calendar.startOfDay(for: .now)
            let tomorrow = try #require(calendar.date(byAdding: .day, value: 1, to: today))
            try await store.createReminder(ReminderDraft(
                title: "Water the plants",
                listIdentifier: list.calendarIdentifier,
                dueDate: today,
                recurrence: ReminderRecurrence(frequency: .daily)
            ))
            let series = try #require(await reminders(in: store, list: list, from: today).first)
            #expect(series.isRecurring)

            try await store.setCompleted(true, for: series)

            let after = await reminders(in: store, list: list, from: today)
            let open = try #require(after.first { !$0.isCompleted })
            let done = try #require(after.first { $0.isCompleted })
            #expect(after.count == 2)
            #expect(open.id == series.id)
            #expect(open.isRecurring)
            #expect(open.dueDate.map { calendar.startOfDay(for: $0) } == tomorrow)
            #expect(done.id != series.id)
            #expect(!done.isRecurring)
            #expect(done.dueDate.map { calendar.startOfDay(for: $0) } == today)
        }
    }
}
