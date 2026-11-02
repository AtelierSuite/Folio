import Foundation
import Testing
@testable import Planner

@MainActor
struct UndoConversionTests {
    private let groceries = Fixtures.reminder(local: "Groceries", due: Fixtures.date(2026, 10, 29, hour: 17))

    @Test func convertingAnEventCreatesAReminderAndDeletesTheEventOnceTheToastExpires() async throws {
        let lunch = UndoTestContext.event("Lunch")
        let context = try UndoTestContext(events: [lunch])
        try await context.coordinator.convertEvent(lunch, toReminderIn: "list-1")

        #expect(context.coordinator.toast?.action == .convert(.event))
        #expect(context.source.storedReminders.map(\.title) == ["Lunch"])
        #expect(await context.visibleEventTitles().isEmpty)
        #expect(context.deleteCalls.isEmpty)
        context.coordinator.expireToast()
        await context.coordinator.settle()
        #expect(context.source.currentEvents.isEmpty)
    }

    @Test func undoingAnEventConversionRemovesTheReminderAndRedoMakesItAgain() async throws {
        let lunch = UndoTestContext.event("Lunch")
        let context = try UndoTestContext(events: [lunch])
        try await context.coordinator.convertEvent(lunch, toReminderIn: "list-1")

        await context.undo()
        #expect(context.source.storedReminders.isEmpty)
        #expect(await context.visibleEventTitles() == ["Lunch"])
        await context.redo()
        #expect(context.source.storedReminders.map(\.title) == ["Lunch"])
        #expect(await context.visibleEventTitles().isEmpty)
    }

    @Test func convertingARepeatingEventConvertsTheWholeSeries() async throws {
        let series = UndoTestContext.series("Standup", days: 27...29)
        let context = try UndoTestContext(events: series)
        try await context.coordinator.convertEvent(try #require(series.last), toReminderIn: "list-1")

        #expect(context.source.storedReminders.map(\.recurrence?.frequency) == [.daily])
        #expect(context.store.pendingRemovals.values.allSatisfy { removal in series.allSatisfy(removal.hides) })
        #expect(await context.visibleEventTitles().isEmpty)
    }

    @Test func convertingAReminderCreatesAnEventAndDeletesTheReminderOnceTheToastExpires() async throws {
        let context = try UndoTestContext(reminders: [groceries])
        try await context.coordinator.convertReminder(groceries, toEventIn: "work")

        #expect(context.coordinator.toast?.action == .convert(.reminder))
        #expect(context.source.currentEvents.map(\.title) == ["Groceries"])
        #expect(context.store.pendingRemovals.values.contains { $0.hides(groceries) })
        #expect(context.source.storedReminders.count == 1)
        context.coordinator.expireToast()
        await context.coordinator.settle()
        #expect(context.source.storedReminders.isEmpty)
    }

    @Test func undoingAReminderConversionRemovesTheEvent() async throws {
        let context = try UndoTestContext(reminders: [groceries])
        try await context.coordinator.convertReminder(groceries, toEventIn: "work")

        await context.undo()
        #expect(context.source.currentEvents.isEmpty)
        #expect(context.store.pendingRemovals.isEmpty)
        #expect(context.source.storedReminders.map(\.reference) == [groceries.reference])
    }
}
