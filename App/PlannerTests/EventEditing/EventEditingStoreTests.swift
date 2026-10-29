import Foundation
import Testing
@testable import Planner

@MainActor
struct EventEditingStoreTests {
    private let work = Fixtures.plannerCalendar("work")
    private let holidays = PlannerCalendar(
        id: "holidays", title: "Holidays", kind: .event, color: .gray,
        sourceIdentifier: "source", sourceTitle: "Subscribed", sourceType: .subscription, isReadOnly: true
    )

    private func makeStore(_ source: FakeCalendarDataSource) throws -> CalendarStore {
        let defaults = try #require(UserDefaults(suiteName: "EventEditingStoreTests.\(UUID().uuidString)"))
        return CalendarStore(
            source: source,
            policy: CacheWindowPolicy(paddingWeeks: 1, calendar: Fixtures.calendar),
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults)
        )
    }

    private func dailySeries(days: ClosedRange<Int>) -> [CalendarEvent] {
        days.map { day in
            let start = Fixtures.date(2026, 10, day, hour: 9)
            return FakeCalendarDataSource.event(
                from: EventDraft(
                    title: "Standup", calendarIdentifier: "work",
                    startDate: start, endDate: start.addingTimeInterval(900),
                    recurrence: EventRecurrence(frequency: .daily)
                ),
                localIdentifier: "standup",
                occurrenceDate: start
            )
        }
    }

    private func editedDraft(of event: CalendarEvent, title: String, hourShift: Double = 0) -> EventDraft {
        EventDraft(
            title: title, calendarIdentifier: event.calendarIdentifier,
            startDate: event.startDate.addingTimeInterval(hourShift * 3600),
            endDate: event.endDate.addingTimeInterval(hourShift * 3600),
            recurrence: EventRecurrence(frequency: .daily)
        )
    }

    @Test func defaultCalendarSkipsReadOnlyCalendars() throws {
        let source = FakeCalendarDataSource(calendars: [holidays, work])
        source.setDefaultEventCalendarIdentifier("holidays")
        let store = try makeStore(source)
        #expect(store.writableEventCalendars.map(\.id) == ["work"])
        #expect(store.defaultEventCalendarIdentifier == "work")
        source.setDefaultEventCalendarIdentifier("work")
        #expect(store.defaultEventCalendarIdentifier == "work")
    }

    @Test func createAddsEventAndBumpsRevision() async throws {
        let source = FakeCalendarDataSource(calendars: [work])
        let store = try makeStore(source)
        let revision = store.contentRevision
        let draft = EventDraft(
            title: "Dentist", calendarIdentifier: "work",
            startDate: Fixtures.date(2026, 10, 29, hour: 15), endDate: Fixtures.date(2026, 10, 29, hour: 16)
        )
        let reference = try await store.createEvent(draft)
        #expect(store.contentRevision > revision)
        #expect(source.eventWriteCalls == [.create(draft)])
        let day = DateInterval(start: Fixtures.date(2026, 10, 29), end: Fixtures.date(2026, 10, 30))
        #expect(await store.events(in: day).map(\.reference) == [reference])
        let found = await store.event(matching: reference, near: draft.startDate, calendar: Fixtures.calendar)
        #expect(found?.title == "Dentist")
    }

    @Test func createRejectsInvalidDatesAndReadOnlyCalendars() async throws {
        let source = FakeCalendarDataSource(calendars: [work, holidays])
        let store = try makeStore(source)
        let backwards = EventDraft(
            calendarIdentifier: "work",
            startDate: Fixtures.date(2026, 10, 29, hour: 16), endDate: Fixtures.date(2026, 10, 29, hour: 15)
        )
        await #expect(throws: EventEditingError.invalidDates) { try await store.createEvent(backwards) }
        var readOnly = backwards
        readOnly.calendarIdentifier = "holidays"
        readOnly.endDate = Fixtures.date(2026, 10, 29, hour: 17)
        await #expect(throws: EventEditingError.noWritableCalendar) { try await store.createEvent(readOnly) }
        #expect(source.eventWriteCalls.isEmpty)
    }

    @Test func readOnlyEventsCannotBeEditedOrDeleted() async throws {
        let event = CalendarEvent(
            reference: Fixtures.reference(local: "holiday", calendarIdentifier: "holidays"),
            calendarIdentifier: "holidays", title: "Holiday",
            startDate: Fixtures.date(2026, 10, 29), endDate: Fixtures.date(2026, 10, 30),
            isAllDay: true, isReadOnly: true
        )
        let source = FakeCalendarDataSource(events: [event], calendars: [work, holidays])
        let store = try makeStore(source)
        let draft = EventDraft(calendarIdentifier: "work", startDate: event.startDate, endDate: event.endDate)
        await #expect(throws: EventEditingError.readOnly) { try await store.updateEvent(event, with: draft) }
        await #expect(throws: EventEditingError.readOnly) { try await store.deleteEvent(event) }
        #expect(source.eventWriteCalls.isEmpty)
    }

    @Test func thisEventOnlyChangesOneOccurrence() async throws {
        let series = dailySeries(days: 27...31)
        let source = FakeCalendarDataSource(events: series, calendars: [work])
        let store = try makeStore(source)
        let draft = editedDraft(of: series[2], title: "Moved", hourShift: 1)
        try await store.updateEvent(series[2], with: draft, span: .thisEvent)
        #expect(source.currentEvents.map(\.title) == ["Standup", "Standup", "Moved", "Standup", "Standup"])
        #expect(source.currentEvents[2].startDate == Fixtures.date(2026, 10, 29, hour: 10))
    }

    @Test func futureEventsChangesThisAndLaterOccurrences() async throws {
        let series = dailySeries(days: 27...31)
        let source = FakeCalendarDataSource(events: series, calendars: [work])
        let store = try makeStore(source)
        let draft = editedDraft(of: series[2], title: "Sync")
        try await store.updateEvent(series[2], with: draft, span: .futureEvents)
        #expect(source.currentEvents.map(\.title) == ["Standup", "Standup", "Sync", "Sync", "Sync"])
        #expect(source.eventWriteCalls.first == .update(series[2].reference, draft, .futureEvents))
    }

    @Test func allEventsEditsTheFirstOccurrenceWithFutureEvents() async throws {
        let series = dailySeries(days: 27...31)
        let source = FakeCalendarDataSource(events: series, calendars: [work])
        let store = try makeStore(source)
        let draft = editedDraft(of: series[3], title: "Daily Sync", hourShift: 1)
        try await store.updateEvent(series[3], with: draft, span: .allEvents, calendar: Fixtures.calendar)
        guard case let .update(reference, seriesDraft, span) = try #require(source.eventWriteCalls.first) else {
            Issue.record("Expected an update")
            return
        }
        #expect(reference == series[0].reference)
        #expect(span == .futureEvents)
        #expect(seriesDraft.startDate == Fixtures.date(2026, 10, 27, hour: 10))
        #expect(source.currentEvents.allSatisfy { $0.title == "Daily Sync" })
        let hours = source.currentEvents.map { Fixtures.calendar.component(.hour, from: $0.startDate) }
        #expect(hours == [10, 10, 10, 10, 10])
    }

    @Test func deleteSpansRemoveTheRightOccurrences() async throws {
        let series = dailySeries(days: 27...31)
        let source = FakeCalendarDataSource(events: series, calendars: [work])
        let store = try makeStore(source)

        try await store.deleteEvent(series[1], span: .thisEvent)
        #expect(source.currentEvents.map(\.startDate) == [series[0], series[2], series[3], series[4]].map(\.startDate))

        try await store.deleteEvent(series[3], span: .futureEvents)
        #expect(source.currentEvents.map(\.startDate) == [series[0], series[2]].map(\.startDate))

        try await store.deleteEvent(series[2], span: .allEvents)
        #expect(source.currentEvents.isEmpty)
        #expect(source.eventWriteCalls.last == .delete(series[0].reference, .futureEvents))
    }

    @Test func nonRecurringEventsAlwaysUseThisEvent() async throws {
        let event = Fixtures.event(
            local: "lunch", calendarIdentifier: "work", start: Fixtures.date(2026, 10, 29, hour: 12)
        )
        let source = FakeCalendarDataSource(events: [event], calendars: [work])
        let store = try makeStore(source)
        try await store.deleteEvent(event, span: .allEvents)
        #expect(source.eventWriteCalls == [.delete(event.reference, .thisEvent)])
        #expect(source.currentEvents.isEmpty)
    }
}
