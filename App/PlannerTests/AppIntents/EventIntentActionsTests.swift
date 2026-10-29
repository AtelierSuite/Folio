import Foundation
import Synchronization
import Testing
@testable import Planner

@MainActor
struct EventIntentActionsTests {
    private let source: FakeCalendarDataSource
    private let actions: EventIntentActions

    init() throws {
        source = FakeCalendarDataSource(calendars: [Fixtures.plannerCalendar("work")])
        source.setDefaultEventCalendarIdentifier("work")
        let store = CalendarStore(source: source, visibilityStorage: try IntentTestSupport.visibilityStorage())
        actions = EventIntentActions(store: store, calendar: Fixtures.calendar)
    }

    private func seed(_ events: [CalendarEvent]) {
        source.replaceEvents(events)
        source.state.withLock { state in
            for event in events {
                state.eventWriting.drafts[event.reference.localIdentifier] = EventDraft(
                    title: event.title,
                    calendarIdentifier: event.calendarIdentifier,
                    startDate: event.startDate,
                    endDate: event.endDate
                )
            }
        }
    }

    @Test func createsAnHourLongEventInTheDefaultCalendar() async throws {
        let start = Fixtures.date(2026, 11, 2, hour: 15)

        let event = try await actions.createEvent(
            NewEventRequest(title: "  Dentist ", startDate: start, location: "Clinic")
        )

        #expect(event.title == "Dentist")
        #expect(event.calendarIdentifier == "work")
        #expect(event.startDate == start)
        #expect(event.endDate == start.addingTimeInterval(3600))
        #expect(event.location == "Clinic")
    }

    @Test func createsAnAllDayEventCoveringTheDay() async throws {
        let request = NewEventRequest(
            title: "Holiday", startDate: Fixtures.date(2026, 11, 2, hour: 15), isAllDay: true
        )

        let event = try await actions.createEvent(request)

        #expect(event.isAllDay)
        #expect(event.startDate == Fixtures.date(2026, 11, 2))
        #expect(event.endDate == Fixtures.date(2026, 11, 3))
    }

    @Test func refusesEmptyTitlesAndMissingAccess() async throws {
        await #expect(throws: PlannerIntentError.emptyTitle) {
            try await actions.createEvent(NewEventRequest(title: " ", startDate: IntentTestSupport.now))
        }
        source.setAuthorization(.denied, for: .event)
        let store = CalendarStore(source: source, visibilityStorage: try IntentTestSupport.visibilityStorage())
        await #expect(throws: PlannerIntentError.noCalendarAccess) {
            try await EventIntentActions(store: store).createEvent(
                NewEventRequest(title: "Lunch", startDate: IntentTestSupport.now)
            )
        }
    }

    @Test func editingMovesTheEventAndKeepsItsLength() async throws {
        let lunch = IntentTestSupport.event("Lunch", start: Fixtures.date(2026, 10, 29, hour: 12), hours: 2)
        seed([lunch])
        let newStart = Fixtures.date(2026, 10, 30, hour: 13)

        let edited = try await actions.editEvent(
            EventEntity(lunch), with: EventChanges(title: "Team lunch", startDate: newStart)
        )

        #expect(edited.title == "Team lunch")
        #expect(edited.startDate == newStart)
        #expect(edited.endDate == newStart.addingTimeInterval(7200))
    }

    @Test func editingARecurringEventChangesOnlyThatOccurrence() async throws {
        let occurrences = (29...30).map { day in
            let start = Fixtures.date(2026, 10, day, hour: 9)
            return IntentTestSupport.event("Standup", start: start, occurrence: start)
        }
        seed(occurrences)

        _ = try await actions.editEvent(EventEntity(occurrences[1]), with: EventChanges(title: "Retro"))

        guard case .update(let reference, _, let span) = source.eventWriteCalls.last else {
            Issue.record("Expected an update")
            return
        }
        #expect(reference.occurrenceDate == occurrences[1].reference.occurrenceDate)
        #expect(span == .thisEvent)
        #expect(source.currentEvents.map(\.title) == ["Standup", "Retro"])
    }

    @Test func deletesTheEventItWasGiven() async throws {
        let lunch = IntentTestSupport.event("Lunch", start: Fixtures.date(2026, 10, 29, hour: 12))
        let dinner = IntentTestSupport.event("Dinner", start: Fixtures.date(2026, 10, 29, hour: 19))
        seed([lunch, dinner])

        try await actions.deleteEvent(EventEntity(lunch))

        #expect(source.currentEvents.map(\.title) == ["Dinner"])
    }

    @Test func reportsEventsThatAreGoneOrReadOnly() async throws {
        let holiday = CalendarEvent(
            reference: Fixtures.reference(external: "holiday", local: "holiday", title: "Holiday"),
            calendarIdentifier: "work",
            title: "Holiday",
            startDate: Fixtures.date(2026, 10, 29),
            endDate: Fixtures.date(2026, 10, 30),
            isAllDay: true,
            isReadOnly: true
        )
        seed([holiday])
        let gone = IntentTestSupport.event("Gone", start: Fixtures.date(2026, 10, 29, hour: 12))

        await #expect(throws: PlannerIntentError.eventNotFound) {
            try await actions.deleteEvent(EventEntity(gone))
        }
        await #expect(throws: PlannerIntentError.readOnly) {
            try await actions.deleteEvent(EventEntity(holiday))
        }
    }
}
