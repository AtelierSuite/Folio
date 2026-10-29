import Foundation

extension CalendarStore {
    public var writableEventCalendars: [PlannerCalendar] {
        eventCalendars.filter { !$0.isReadOnly }
    }

    public var defaultEventCalendarIdentifier: String? {
        let writableIdentifiers = Set(writableEventCalendars.map(\.id))
        if let identifier = source.defaultEventCalendarIdentifier(), writableIdentifiers.contains(identifier) {
            return identifier
        }
        return writableEventCalendars.first?.id
    }

    public func eventDraft(for event: CalendarEvent) async throws -> EventDraft {
        try await source.eventDraft(for: event.reference)
    }

    public func event(
        matching reference: CalendarItemReference,
        near date: Date,
        calendar: Calendar = .current
    ) async -> CalendarEvent? {
        let day = calendar.startOfDay(for: date)
        let interval = DateInterval(
            start: calendar.date(byAdding: .day, value: -1, to: day) ?? day,
            end: calendar.date(byAdding: .day, value: 2, to: day) ?? day
        )
        let candidates = await repository.events(in: interval)
        guard let match = reference.bestMatch(in: candidates.map(\.reference)) else { return nil }
        return candidates.first { $0.reference == match }
    }

    @discardableResult
    public func createEvent(_ draft: EventDraft) async throws -> CalendarItemReference {
        try validate(draft)
        let reference = try await source.createEvent(draft)
        await handleExternalChange()
        return reference
    }

    @discardableResult
    public func updateEvent(
        _ event: CalendarEvent,
        with draft: EventDraft,
        span: EventEditSpan = .thisEvent,
        calendar: Calendar = .current
    ) async throws -> CalendarItemReference {
        guard !event.isReadOnly else { throw EventEditingError.readOnly }
        try validate(draft)
        let reference: CalendarItemReference
        if event.isRecurring && span == .allEvents {
            let firstOccurrence = try await source.firstOccurrence(of: event.reference)
            let seriesDraft = draft.appliedToSeries(
                editedOccurrenceStart: event.startDate,
                firstOccurrenceStart: firstOccurrence.startDate,
                calendar: calendar
            )
            reference = try await source.updateEvent(firstOccurrence.reference, with: seriesDraft, span: .futureEvents)
        } else {
            let occurrenceSpan: EventEditSpan = event.isRecurring ? span : .thisEvent
            reference = try await source.updateEvent(event.reference, with: draft, span: occurrenceSpan)
        }
        await handleExternalChange()
        return reference
    }

    public func deleteEvent(_ event: CalendarEvent, span: EventEditSpan = .thisEvent) async throws {
        guard !event.isReadOnly else { throw EventEditingError.readOnly }
        if event.isRecurring && span == .allEvents {
            let firstOccurrence = try await source.firstOccurrence(of: event.reference)
            try await source.deleteEvent(firstOccurrence.reference, span: .futureEvents)
        } else {
            try await source.deleteEvent(event.reference, span: event.isRecurring ? span : .thisEvent)
        }
        await handleExternalChange()
    }

    private func validate(_ draft: EventDraft) throws {
        guard draft.hasValidDates else { throw EventEditingError.invalidDates }
        guard writableEventCalendars.contains(where: { $0.id == draft.calendarIdentifier }) else {
            throw EventEditingError.noWritableCalendar
        }
    }
}
