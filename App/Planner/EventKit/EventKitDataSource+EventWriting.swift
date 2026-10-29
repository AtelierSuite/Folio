import EventKit

extension EventKitDataSource {
    public func defaultEventCalendarIdentifier() -> String? {
        eventStore.defaultCalendarForNewEvents?.calendarIdentifier
    }

    public func eventDraft(for reference: CalendarItemReference) async throws -> EventDraft {
        EventDraft(try event(for: reference))
    }

    public func firstOccurrence(of reference: CalendarItemReference) async throws -> CalendarEvent {
        guard let event = eventStore.calendarItem(withIdentifier: reference.localIdentifier) as? EKEvent else {
            throw CalendarDataSourceError.itemNotFound
        }
        return CalendarEvent(event)
    }

    public func createEvent(_ draft: EventDraft) async throws -> CalendarItemReference {
        guard eventStore.calendar(withIdentifier: draft.calendarIdentifier) != nil else {
            throw EventEditingError.noWritableCalendar
        }
        let event = EKEvent(eventStore: eventStore)
        draft.apply(to: event, in: eventStore, original: nil)
        try eventStore.save(event, span: .futureEvents, commit: true)
        return CalendarItemReference(event)
    }

    public func updateEvent(
        _ reference: CalendarItemReference,
        with draft: EventDraft,
        span: EventEditSpan
    ) async throws -> CalendarItemReference {
        let event = try event(for: reference)
        draft.apply(to: event, in: eventStore, original: EventDraft(event))
        try eventStore.save(event, span: span.eventKitSpan, commit: true)
        return CalendarItemReference(event)
    }

    public func deleteEvent(_ reference: CalendarItemReference, span: EventEditSpan) async throws {
        try eventStore.remove(try event(for: reference), span: span.eventKitSpan, commit: true)
    }

    func event(for reference: CalendarItemReference) throws -> EKEvent {
        guard let occurrenceDate = reference.occurrenceDate else {
            guard let event = eventStore.calendarItem(withIdentifier: reference.localIdentifier) as? EKEvent else {
                throw CalendarDataSourceError.itemNotFound
            }
            return event
        }
        let anchor = reference.startDate ?? occurrenceDate
        let predicate = eventStore.predicateForEvents(
            withStart: min(anchor, occurrenceDate).addingTimeInterval(-86400),
            end: max(anchor, occurrenceDate).addingTimeInterval(86400),
            calendars: nil
        )
        let candidates = eventStore.events(matching: predicate)
        guard let match = reference.bestMatch(in: candidates.map(CalendarItemReference.init)),
              let event = candidates.first(where: { CalendarItemReference($0) == match }) else {
            throw CalendarDataSourceError.itemNotFound
        }
        return event
    }
}

extension EventEditSpan {
    var eventKitSpan: EKSpan {
        self == .thisEvent ? .thisEvent : .futureEvents
    }
}
