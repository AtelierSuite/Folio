import Foundation
import Testing
@testable import Planner

@MainActor
struct UndoReminderTests {
    private let groceries = Fixtures.reminder(local: "Groceries", due: Fixtures.date(2026, 10, 29, hour: 17))

    @Test func deleteHidesTheReminderUntilTheToastExpires() async throws {
        let context = try UndoTestContext(reminders: [groceries])
        try await context.coordinator.deleteReminder(groceries)

        #expect(await context.visibleReminderTitles().isEmpty)
        #expect(context.source.storedReminders.count == 1)
        context.coordinator.expireToast()
        await context.coordinator.settle()
        #expect(context.source.storedReminders.isEmpty)
    }

    @Test func undoingADeleteKeepsTheSameReminder() async throws {
        let context = try UndoTestContext(reminders: [groceries])
        try await context.coordinator.deleteReminder(groceries)
        context.coordinator.undoToast()
        await context.coordinator.commitPending()

        #expect(context.source.storedReminders.map(\.reference) == [groceries.reference])
        #expect(await context.visibleReminderTitles() == ["Groceries"])
    }

    @Test func editsSaveImmediatelyAndUndoSavesTheOldValues() async throws {
        let context = try UndoTestContext(reminders: [groceries])
        var draft = ReminderDraft(groceries)
        draft.title = "Groceries and flowers"
        try await context.coordinator.updateReminder(groceries, with: draft)

        #expect(context.source.storedReminders.map(\.title) == ["Groceries and flowers"])
        await context.undo()
        #expect(context.source.storedReminders.map(\.title) == ["Groceries"])
        await context.redo()
        #expect(context.source.storedReminders.map(\.title) == ["Groceries and flowers"])
    }

    @Test func completingCanBeUndone() async throws {
        let context = try UndoTestContext(reminders: [groceries])
        try await context.coordinator.setCompleted(true, for: groceries)

        #expect(context.source.completedReminderIdentifiers["Groceries"] == true)
        #expect(context.coordinator.toast?.action == .complete)
        context.coordinator.undoToast()
        await context.coordinator.settle()
        #expect(context.source.completedReminderIdentifiers["Groceries"] == false)
    }
}
