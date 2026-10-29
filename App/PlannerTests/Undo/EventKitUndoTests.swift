import EventKit
import Foundation
import Testing
@testable import Planner

/// Runs against the real event store hosted in the app, like `EventKitEventWritingTests`.
@MainActor
@Suite(.serialized, .enabled(if: EKEventStore.authorizationStatus(for: .event) == .fullAccess))
struct EventKitUndoTests {
    private let source = EventKitDataSource.shared
    private let calendar = Calendar.current

    private func withSeries(_ body: (CalendarStore, UndoCoordinator, [CalendarEvent]) async throws -> Void) async throws {
        let eventStore = source.eventStore
        let temporaryCalendar = EKCalendar(for: .event, eventStore: eventStore)
        temporaryCalendar.title = "Folio Undo Tests \(UUID().uuidString)"
        temporaryCalendar.source = try #require(
            eventStore.defaultCalendarForNewEvents?.source ?? eventStore.sources.first { $0.sourceType == .local }
        )
        try eventStore.saveCalendar(temporaryCalendar, commit: true)
        defer { try? eventStore.removeCalendar(temporaryCalendar, commit: true) }
        let defaults = try #require(UserDefaults(suiteName: "EventKitUndoTests.\(UUID().uuidString)"))
        let store = CalendarStore(source: source, visibilityStorage: CalendarVisibilityStorage(defaults: defaults))
        let firstDay = calendar.date(byAdding: .day, value: 40, to: calendar.startOfDay(for: .now)) ?? .now
        let start = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: firstDay) ?? firstDay
        try await store.createEvent(EventDraft(
            title: "Series", calendarIdentifier: temporaryCalendar.calendarIdentifier,
            startDate: start, endDate: start.addingTimeInterval(1800),
            recurrence: EventRecurrence(frequency: .daily, end: .afterOccurrences(5))
        ))
        let interval = DateInterval(start: firstDay, duration: 6 * 86400)
        let events = await store.events(in: interval)
            .filter { $0.calendarIdentifier == temporaryCalendar.calendarIdentifier }
        try await body(store, UndoCoordinator(store: store), events)
    }

    private func storedOccurrences(of event: CalendarEvent) -> [EKEvent] {
        let predicate = source.eventStore.predicateForEvents(
            withStart: event.startDate.addingTimeInterval(-6 * 86400),
            end: event.startDate.addingTimeInterval(6 * 86400),
            calendars: nil
        )
        return source.eventStore.events(matching: predicate)
            .filter { $0.calendarItemIdentifier == event.reference.localIdentifier }
    }

    @Test func undoingADeleteKeepsTheSameEventAndSeries() async throws {
        try await withSeries { store, coordinator, events in
            #expect(events.count == 5)
            let deleted = events[2]
            try await coordinator.deleteEvent(deleted, span: .thisEvent)
            #expect(storedOccurrences(of: deleted).count == 5)

            coordinator.undoToast()
            await coordinator.commitPending()
            let occurrences = storedOccurrences(of: deleted)
            #expect(occurrences.count == 5)
            #expect(occurrences.allSatisfy { $0.hasRecurrenceRules && !$0.isDetached })
            #expect(occurrences.map(\.calendarItemExternalIdentifier).allSatisfy {
                $0 == deleted.reference.externalIdentifier
            })
            #expect(store.contentRevision > 0)
        }
    }

    @Test func expiredDeletesRemoveTheOccurrence() async throws {
        try await withSeries { _, coordinator, events in
            try await coordinator.deleteEvent(events[2], span: .thisEvent)
            coordinator.expireToast()
            await coordinator.settle()
            #expect(storedOccurrences(of: events[2]).count == 4)
        }
    }

    @Test func undoingAFutureEventsEditLeavesTheSeriesWhole() async throws {
        try await withSeries { _, coordinator, events in
            var draft = try await coordinator.store.eventDraft(for: events[2])
            draft.title = "Split"
            try await coordinator.updateEvent(events[2], with: draft, span: .futureEvents)
            coordinator.undoToast()
            await coordinator.commitPending()

            let occurrences = storedOccurrences(of: events[0])
            #expect(occurrences.count == 5)
            #expect(occurrences.allSatisfy { $0.title == "Series" })
        }
    }
}
