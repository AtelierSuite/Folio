import Foundation
import Testing
@testable import Planner

@MainActor
struct UndoEventDeleteTests {
    @Test func deleteHidesTheEventWithoutDeletingIt() async throws {
        let context = try UndoTestContext(events: [UndoTestContext.event("Lunch"), UndoTestContext.event("Gym", hour: 18)])
        try await context.coordinator.deleteEvent(UndoTestContext.event("Lunch"))

        #expect(await context.visibleEventTitles() == ["Gym"])
        #expect(context.source.currentEvents.map(\.title) == ["Lunch", "Gym"])
        #expect(context.deleteCalls.isEmpty)
        #expect(context.coordinator.toast?.action == .delete(.event))
        #expect(context.coordinator.hasPendingCommit)
    }

    @Test func toastExpiryDeletesTheEvent() async throws {
        let context = try UndoTestContext(events: [UndoTestContext.event("Lunch")])
        try await context.coordinator.deleteEvent(UndoTestContext.event("Lunch"))
        context.coordinator.expireToast()
        await context.coordinator.settle()

        #expect(context.coordinator.toast == nil)
        #expect(context.source.currentEvents.isEmpty)
        #expect(context.deleteCalls.count == 1)
        #expect(!context.store.hasPendingChanges)
        #expect(!context.undoManager.canUndo)
    }

    @Test func toastTimerDeletesTheEventAfterItsDuration() async throws {
        let context = try UndoTestContext(events: [UndoTestContext.event("Lunch")], toastDuration: .milliseconds(50))
        try await context.coordinator.deleteEvent(UndoTestContext.event("Lunch"))
        #expect(!context.source.currentEvents.isEmpty)

        for _ in 0..<100 where !context.source.currentEvents.isEmpty {
            try await Task.sleep(for: .milliseconds(20))
        }
        await context.coordinator.settle()
        #expect(context.source.currentEvents.isEmpty)
        #expect(context.coordinator.toast == nil)
    }

    @Test func assistiveTechnologiesKeepTheToastUpLonger() async throws {
        let source = FakeCalendarDataSource(events: [UndoTestContext.event("Lunch")], calendars: [Fixtures.plannerCalendar("work")])
        let defaults = try #require(UserDefaults(suiteName: "UndoTests.\(UUID().uuidString)"))
        let store = CalendarStore(source: source, visibilityStorage: CalendarVisibilityStorage(defaults: defaults))
        let coordinator = UndoCoordinator(
            store: store, toastDuration: .milliseconds(20), assistiveToastDuration: .seconds(60)
        )
        coordinator.isAssistiveTechnologyRunning = true
        try await coordinator.deleteEvent(UndoTestContext.event("Lunch"))
        try await Task.sleep(for: .milliseconds(200))

        #expect(coordinator.toast != nil)
        #expect(!source.currentEvents.isEmpty)
    }

    @Test func undoWithinTheWindowKeepsTheSameEvent() async throws {
        let lunch = UndoTestContext.event("Lunch")
        let context = try UndoTestContext(events: [lunch])
        try await context.coordinator.deleteEvent(lunch)
        context.coordinator.undoToast()
        await context.coordinator.settle()

        let restored = await context.store.events(in: context.week)
        #expect(restored.map(\.reference) == [lunch.reference])
        #expect(context.source.eventWriteCalls.isEmpty)
        #expect(context.coordinator.toast == nil)
        #expect(!context.coordinator.hasPendingCommit)
    }

    @Test func backgroundingCommitsTheDelete() async throws {
        let context = try UndoTestContext(events: [UndoTestContext.event("Lunch")])
        try await context.coordinator.deleteEvent(UndoTestContext.event("Lunch"))
        await context.coordinator.commitPending()

        #expect(context.source.currentEvents.isEmpty)
        #expect(context.coordinator.toast == nil)
    }

    @Test func theNextActionCommitsThePreviousDelete() async throws {
        let context = try UndoTestContext(events: [UndoTestContext.event("Lunch"), UndoTestContext.event("Gym", hour: 18)])
        try await context.coordinator.deleteEvent(UndoTestContext.event("Lunch"))
        try await context.coordinator.deleteEvent(UndoTestContext.event("Gym", hour: 18))

        #expect(context.source.currentEvents.map(\.title) == ["Gym"])
        #expect(await context.visibleEventTitles().isEmpty)
        #expect(context.deleteCalls.count == 1)
    }

    @Test func quittingWithinTheWindowDeletesNothing() async throws {
        let source = FakeCalendarDataSource(events: [UndoTestContext.event("Lunch")], calendars: [Fixtures.plannerCalendar("work")])
        let defaults = try #require(UserDefaults(suiteName: "UndoTests.\(UUID().uuidString)"))
        var store: CalendarStore? = CalendarStore(source: source, visibilityStorage: CalendarVisibilityStorage(defaults: defaults))
        var coordinator: UndoCoordinator? = UndoCoordinator(store: try #require(store))
        try await coordinator?.deleteEvent(UndoTestContext.event("Lunch"))
        coordinator = nil
        store = nil

        let relaunchedStore = CalendarStore(source: source, visibilityStorage: CalendarVisibilityStorage(defaults: defaults))
        let week = DateInterval(start: Fixtures.date(2026, 10, 25), end: Fixtures.date(2026, 11, 1))
        #expect(await relaunchedStore.events(in: week).map(\.title) == ["Lunch"])
        #expect(source.eventWriteCalls.isEmpty)
    }

    @Test func deletingFutureOccurrencesHidesOnlyThoseOccurrences() async throws {
        let series = UndoTestContext.series("Standup", days: 26...30)
        let context = try UndoTestContext(events: series)
        try await context.coordinator.deleteEvent(series[2], span: .futureEvents)

        let visibleDays = await context.store.events(in: context.week).map {
            Fixtures.calendar.component(.day, from: $0.startDate)
        }
        #expect(visibleDays.sorted() == [26, 27])
        context.coordinator.expireToast()
        await context.coordinator.settle()
        #expect(context.deleteCalls == [.delete(series[2].reference, .futureEvents)])
    }

    @Test func undoManagerUndoesAndRedoesADelete() async throws {
        let lunch = UndoTestContext.event("Lunch")
        let context = try UndoTestContext(events: [lunch])
        try await context.coordinator.deleteEvent(lunch)
        #expect(context.undoManager.undoActionName == UndoAction.delete(.event).actionName)

        await context.undo()
        #expect(await context.visibleEventTitles() == ["Lunch"])
        #expect(context.coordinator.toast == nil)
        #expect(context.undoManager.canRedo)

        await context.redo()
        #expect(await context.visibleEventTitles().isEmpty)
        #expect(context.coordinator.toast?.action == .delete(.event))
        #expect(context.deleteCalls.isEmpty)

        context.coordinator.expireToast()
        await context.coordinator.settle()
        #expect(context.deleteCalls == [.delete(lunch.reference, .thisEvent)])
        #expect(!context.undoManager.canUndo)
    }

    @Test func toastUndoGoesThroughTheUndoManagerSoRedoWorksLater() async throws {
        let lunch = UndoTestContext.event("Lunch")
        let context = try UndoTestContext(events: [lunch])
        try await context.coordinator.deleteEvent(lunch)
        context.coordinator.undoToast()
        await context.coordinator.settle()

        #expect(!context.undoManager.canUndo)
        #expect(context.undoManager.canRedo)
        await context.redo()
        #expect(await context.visibleEventTitles().isEmpty)
    }

    @Test func readOnlyEventsAreNotDeleted() async throws {
        let context = try UndoTestContext()
        let event = CalendarEvent(
            reference: Fixtures.reference(), calendarIdentifier: "work", title: "Holiday",
            startDate: Fixtures.date(2026, 10, 29), endDate: Fixtures.date(2026, 10, 30), isReadOnly: true
        )
        await #expect(throws: EventEditingError.readOnly) {
            try await context.coordinator.deleteEvent(event)
        }
        #expect(context.coordinator.toast == nil)
    }

    @Test func searchSkipsResultsWaitingToBeDeleted() async throws {
        let lunch = UndoTestContext.event("Lunch")
        let gym = UndoTestContext.event("Gym", hour: 18)
        let context = try UndoTestContext(events: [lunch, gym])
        try await context.coordinator.deleteEvent(lunch)

        #expect(context.store.isPendingRemoval(SearchDocument(event: lunch)))
        #expect(!context.store.isPendingRemoval(SearchDocument(event: gym)))
    }
}
