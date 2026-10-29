import Foundation
import Testing
@testable import Planner

@MainActor
struct UndoEventEditTests {
    private func moved(_ event: CalendarEvent, hours: Double, title: String? = nil) -> EventDraft {
        var draft = UndoTestContext.draft(of: event)
        draft.title = title ?? event.title
        draft.startDate = event.startDate.addingTimeInterval(hours * 3600)
        draft.endDate = event.endDate.addingTimeInterval(hours * 3600)
        return draft
    }

    @Test func simpleEditsSaveImmediatelyAndUndoSavesTheOldValues() async throws {
        let lunch = UndoTestContext.event("Lunch", hour: 12)
        let context = try UndoTestContext(events: [lunch])
        try await context.coordinator.updateEvent(lunch, with: moved(lunch, hours: 1, title: "Late lunch"))

        #expect(context.source.currentEvents.map(\.title) == ["Late lunch"])
        #expect(context.coordinator.toast?.action == .edit(.event))
        #expect(!context.coordinator.hasPendingCommit)

        context.coordinator.undoToast()
        await context.coordinator.settle()
        #expect(context.source.currentEvents.map(\.title) == ["Lunch"])
        #expect(context.source.currentEvents.first?.startDate == lunch.startDate)
        #expect(context.source.currentEvents.first?.reference.localIdentifier == "Lunch")
    }

    @Test func redoWorksLongAfterTheToastIsGone() async throws {
        let lunch = UndoTestContext.event("Lunch", hour: 12)
        let context = try UndoTestContext(events: [lunch])
        try await context.coordinator.updateEvent(lunch, with: moved(lunch, hours: 2), action: .move(.event))
        context.coordinator.expireToast()
        #expect(context.undoManager.undoActionName == UndoAction.move(.event).actionName)

        await context.undo()
        #expect(context.source.currentEvents.first?.startDate == lunch.startDate)
        await context.redo()
        #expect(context.source.currentEvents.first?.startDate == lunch.startDate.addingTimeInterval(7200))
        #expect(context.coordinator.toast?.action == .move(.event))
        await context.undo()
        #expect(context.source.currentEvents.first?.startDate == lunch.startDate)
    }

    @Test func futureEventsEditsAreHeldAndPreviewedUntilTheToastExpires() async throws {
        let series = UndoTestContext.series("Standup", days: 26...30)
        let context = try UndoTestContext(events: series)
        try await context.coordinator.updateEvent(
            series[2], with: moved(series[2], hours: 1, title: "Sync"), span: .futureEvents
        )

        #expect(context.source.eventWriteCalls.isEmpty)
        #expect(await context.visibleEventTitles() == ["Standup", "Standup", "Sync", "Sync", "Sync"])
        let preview = try #require(await context.store.events(in: context.week).last)
        #expect(Fixtures.calendar.component(.hour, from: preview.startDate) == 10)
        #expect(try await context.store.eventDraft(for: preview).title == "Sync")

        context.coordinator.expireToast()
        await context.coordinator.settle()
        #expect(context.source.eventWriteCalls.count == 1)
        #expect(context.source.currentEvents.map(\.title) == ["Standup", "Standup", "Sync", "Sync", "Sync"])
        #expect(!context.store.hasPendingChanges)
    }

    @Test func undoingAHeldEditWritesNothing() async throws {
        let series = UndoTestContext.series("Standup", days: 26...30)
        let context = try UndoTestContext(events: series)
        try await context.coordinator.updateEvent(
            series[2], with: moved(series[2], hours: 1, title: "Sync"), span: .futureEvents
        )
        context.coordinator.undoToast()
        await context.coordinator.commitPending()

        #expect(context.source.eventWriteCalls.isEmpty)
        #expect(await context.visibleEventTitles() == Array(repeating: "Standup", count: 5))
    }

    @Test func futureEventsFromTheFirstOccurrenceSavesTheSeriesAtOnce() async throws {
        let series = UndoTestContext.series("Standup", days: 26...30)
        let context = try UndoTestContext(events: series)
        try await context.coordinator.updateEvent(
            series[0], with: moved(series[0], hours: 0, title: "Sync"), span: .futureEvents
        )

        #expect(!context.coordinator.hasPendingCommit)
        #expect(context.source.currentEvents.map(\.title) == Array(repeating: "Sync", count: 5))
        context.coordinator.undoToast()
        await context.coordinator.settle()
        #expect(context.source.currentEvents.map(\.title) == Array(repeating: "Standup", count: 5))
    }

    @Test func allEventsEditsSaveTheSeriesAndUndoRestoresIt() async throws {
        let series = UndoTestContext.series("Standup", days: 26...30)
        let context = try UndoTestContext(events: series)
        try await context.coordinator.updateEvent(series[3], with: moved(series[3], hours: 1), span: .allEvents)

        let hours = context.source.currentEvents.map { Fixtures.calendar.component(.hour, from: $0.startDate) }
        #expect(hours == Array(repeating: 10, count: 5))
        await context.undo()
        let restoredHours = context.source.currentEvents.map { Fixtures.calendar.component(.hour, from: $0.startDate) }
        #expect(restoredHours == Array(repeating: 9, count: 5))
    }

    @Test func editingCommitsAStagedDeleteFirst() async throws {
        let lunch = UndoTestContext.event("Lunch", hour: 12)
        let gym = UndoTestContext.event("Gym", hour: 18)
        let context = try UndoTestContext(events: [lunch, gym])
        try await context.coordinator.deleteEvent(gym)
        try await context.coordinator.updateEvent(lunch, with: moved(lunch, hours: 1))

        #expect(context.source.currentEvents.map(\.title) == ["Lunch"])
        #expect(context.coordinator.toast?.action == .edit(.event))
    }
}
