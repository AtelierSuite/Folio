import EventKit
import Foundation
import Testing
@testable import Planner

/// Runs against the real event store and skips without calendar access. TCC refuses the bare
/// `xctest` runner, so run it hosted in the app after granting the app calendar access:
/// `xcodebuild test -only-testing:PlannerTests/EventKitEventWritingTests
///  'TEST_HOST=$(BUILT_PRODUCTS_DIR)/Folio.app/Folio' USES_XCTRUNNER=NO` (build the app first).
@MainActor
@Suite(.serialized, .enabled(if: EKEventStore.authorizationStatus(for: .event) == .fullAccess))
struct EventKitEventWritingTests {
    private let source = EventKitDataSource.shared
    private let calendar = Calendar.current

    private func withTemporaryCalendar(_ body: (CalendarStore, EKCalendar) async throws -> Void) async throws {
        let eventStore = source.eventStore
        let temporaryCalendar = EKCalendar(for: .event, eventStore: eventStore)
        temporaryCalendar.title = "Folio Tests \(UUID().uuidString)"
        temporaryCalendar.source = try #require(
            eventStore.defaultCalendarForNewEvents?.source ?? eventStore.sources.first { $0.sourceType == .local }
        )
        try eventStore.saveCalendar(temporaryCalendar, commit: true)
        defer { try? eventStore.removeCalendar(temporaryCalendar, commit: true) }
        let defaults = try #require(UserDefaults(suiteName: "EventKitEventWritingTests.\(UUID().uuidString)"))
        let store = CalendarStore(source: source, visibilityStorage: CalendarVisibilityStorage(defaults: defaults))
        try await body(store, temporaryCalendar)
    }

    private func occurrences(
        in store: CalendarStore,
        calendar eventCalendar: EKCalendar,
        from start: Date
    ) async -> [CalendarEvent] {
        let interval = DateInterval(start: start, duration: 5 * 86400)
        return await store.events(in: interval).filter { $0.calendarIdentifier == eventCalendar.calendarIdentifier }
    }

    private func makeSeries(in store: CalendarStore, calendar eventCalendar: EKCalendar) async throws -> Date {
        let firstDay = calendar.date(byAdding: .day, value: 30, to: calendar.startOfDay(for: .now)) ?? .now
        let start = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: firstDay) ?? firstDay
        let draft = EventDraft(
            title: "Series",
            calendarIdentifier: eventCalendar.calendarIdentifier,
            startDate: start,
            endDate: start.addingTimeInterval(1800),
            recurrence: EventRecurrence(frequency: .daily, end: .afterOccurrences(5)),
            alerts: [.minutesBefore(10)],
            location: EventLocation(title: "Office", coordinate: EventCoordinate(latitude: 35.68, longitude: 139.76))
        )
        try await store.createEvent(draft)
        return firstDay
    }

    @Test func createdEventRoundTripsItsFields() async throws {
        try await withTemporaryCalendar { store, eventCalendar in
            let firstDay = try await makeSeries(in: store, calendar: eventCalendar)
            let events = await occurrences(in: store, calendar: eventCalendar, from: firstDay)
            #expect(events.count == 5)
            let loaded = try await store.eventDraft(for: try #require(events.first))
            #expect(loaded.recurrence == EventRecurrence(frequency: .daily, end: .afterOccurrences(5)))
            #expect(loaded.alerts == [.minutesBefore(10)])
            #expect(loaded.location?.title == "Office")
            #expect(loaded.location?.coordinate != nil)
        }
    }

    @Test func recurringSpansEditTheRightOccurrences() async throws {
        try await withTemporaryCalendar { store, eventCalendar in
            let firstDay = try await makeSeries(in: store, calendar: eventCalendar)
            var events = await occurrences(in: store, calendar: eventCalendar, from: firstDay)

            var draft = try await store.eventDraft(for: events[1])
            draft.title = "Only Second"
            try await store.updateEvent(events[1], with: draft, span: .thisEvent)
            events = await occurrences(in: store, calendar: eventCalendar, from: firstDay)
            #expect(events.map(\.title) == ["Series", "Only Second", "Series", "Series", "Series"])

            draft = try await store.eventDraft(for: events[3])
            draft.title = "Later"
            try await store.updateEvent(events[3], with: draft, span: .futureEvents)
            events = await occurrences(in: store, calendar: eventCalendar, from: firstDay)
            #expect(events.map(\.title) == ["Series", "Only Second", "Series", "Later", "Later"])

            draft = try await store.eventDraft(for: events[2])
            draft.title = "Everything"
            draft.moveStart(to: draft.startDate.addingTimeInterval(3600))
            try await store.updateEvent(events[2], with: draft, span: .allEvents)
            events = await occurrences(in: store, calendar: eventCalendar, from: firstDay)
            #expect(events.first?.title == "Everything")
            #expect(events.first.map { calendar.component(.hour, from: $0.startDate) } == 10)
            let original = events.filter { $0.reference.localIdentifier == events.first?.reference.localIdentifier }
            #expect(original.count == 2)
            #expect(original.allSatisfy { $0.title == "Everything" })
            #expect(original.allSatisfy { calendar.component(.hour, from: $0.startDate) == 10 })
            #expect(events.contains { $0.title == "Later" })
        }
    }

    @Test func deleteSpansRemoveTheRightOccurrences() async throws {
        try await withTemporaryCalendar { store, eventCalendar in
            let firstDay = try await makeSeries(in: store, calendar: eventCalendar)
            var events = await occurrences(in: store, calendar: eventCalendar, from: firstDay)

            try await store.deleteEvent(events[1], span: .thisEvent)
            events = await occurrences(in: store, calendar: eventCalendar, from: firstDay)
            #expect(events.count == 4)

            try await store.deleteEvent(events[2], span: .futureEvents)
            events = await occurrences(in: store, calendar: eventCalendar, from: firstDay)
            #expect(events.count == 2)

            try await store.deleteEvent(events[1], span: .allEvents)
            events = await occurrences(in: store, calendar: eventCalendar, from: firstDay)
            #expect(events.isEmpty)
        }
    }
}
