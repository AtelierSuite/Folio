import Foundation

/// What the event intents do, against a `CalendarStore` so it shares the app's validation.
/// Recurring events are only ever changed one occurrence at a time.
@MainActor
public struct EventIntentActions {
    private let store: CalendarStore
    private let calendar: Calendar

    public init(store: CalendarStore = CalendarStore(), calendar: Calendar = .current) {
        self.store = store
        self.calendar = calendar
    }

    public func createEvent(_ request: NewEventRequest) async throws -> CalendarEvent {
        try requireAccess()
        let title = request.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { throw PlannerIntentError.emptyTitle }
        guard let calendarIdentifier = request.calendarIdentifier ?? store.defaultEventCalendarIdentifier else {
            throw PlannerIntentError.noWritableCalendar
        }
        let draft = newDraft(for: request, title: title, calendarIdentifier: calendarIdentifier)
        let reference = try await PlannerIntentError.rewording(notFound: .eventNotFound) {
            try await store.createEvent(draft)
        }
        return try await savedEvent(reference, near: draft.startDate)
    }

    public func editEvent(_ entity: EventEntity, with changes: EventChanges) async throws -> CalendarEvent {
        try requireAccess()
        let event = try await event(for: entity)
        guard !event.isReadOnly else { throw PlannerIntentError.readOnly }
        let draft = try await PlannerIntentError.rewording(notFound: .eventNotFound) {
            changes.applied(to: try await store.eventDraft(for: event))
        }
        let reference = try await PlannerIntentError.rewording(notFound: .eventNotFound) {
            try await store.updateEvent(event, with: draft, span: .thisEvent, calendar: calendar)
        }
        return try await savedEvent(reference, near: draft.startDate)
    }

    public func deleteEvent(_ entity: EventEntity) async throws {
        try requireAccess()
        let event = try await event(for: entity)
        try await PlannerIntentError.rewording(notFound: .eventNotFound) {
            try await store.deleteEvent(event, span: .thisEvent)
        }
    }

    public func event(for entity: EventEntity) async throws -> CalendarEvent {
        try requireAccess()
        return try await savedEvent(entity.reference, near: entity.startDate)
    }

    private func requireAccess() throws {
        guard store.eventAuthorization.allowsReading else { throw PlannerIntentError.noCalendarAccess }
    }

    private func newDraft(for request: NewEventRequest, title: String, calendarIdentifier: String) -> EventDraft {
        var draft = EventDraft(
            title: title,
            calendarIdentifier: calendarIdentifier,
            startDate: request.startDate,
            endDate: request.endDate ?? request.startDate.addingTimeInterval(EventDraft.defaultDuration),
            timeZone: calendar.timeZone,
            location: EventLocation(text: request.location),
            notes: request.notes ?? ""
        )
        if request.isAllDay {
            draft.setAllDay(true, calendar: calendar)
        }
        return draft
    }

    private func savedEvent(_ reference: CalendarItemReference, near date: Date) async throws -> CalendarEvent {
        guard let event = await store.event(matching: reference, near: date, calendar: calendar) else {
            throw PlannerIntentError.eventNotFound
        }
        return event
    }
}
