import Foundation
import Synchronization
@testable import Planner

struct FakeEventWriting {
    enum Call: Equatable {
        case create(EventDraft)
        case update(CalendarItemReference, EventDraft, EventEditSpan)
        case delete(CalendarItemReference, EventEditSpan)
    }

    var calls: [Call] = []
    var drafts: [String: EventDraft] = [:]
    var defaultCalendarIdentifier: String?
    var createdCount = 0
}

extension FakeCalendarDataSource {
    var eventWriteCalls: [FakeEventWriting.Call] {
        state.withLock { $0.eventWriting.calls }
    }

    var currentEvents: [CalendarEvent] {
        state.withLock { $0.events }.sorted { $0.startDate < $1.startDate }
    }

    func setDefaultEventCalendarIdentifier(_ identifier: String?) {
        state.withLock { $0.eventWriting.defaultCalendarIdentifier = identifier }
    }

    func defaultEventCalendarIdentifier() -> String? {
        state.withLock { $0.eventWriting.defaultCalendarIdentifier }
    }

    func eventDraft(for reference: CalendarItemReference) async throws -> EventDraft {
        guard let draft = state.withLock({ $0.eventWriting.drafts[reference.localIdentifier] }) else {
            throw CalendarDataSourceError.itemNotFound
        }
        return draft
    }

    func firstOccurrence(of reference: CalendarItemReference) async throws -> CalendarEvent {
        let series = state.withLock { $0.events }.filter { $0.reference.localIdentifier == reference.localIdentifier }
        guard let first = series.min(by: { $0.startDate < $1.startDate }) else {
            throw CalendarDataSourceError.itemNotFound
        }
        return first
    }

    func createEvent(_ draft: EventDraft) async throws -> CalendarItemReference {
        state.withLock { state in
            state.eventWriting.calls.append(.create(draft))
            state.eventWriting.createdCount += 1
            let localIdentifier = "created-\(state.eventWriting.createdCount)"
            let event = Self.event(from: draft, localIdentifier: localIdentifier, occurrenceDate: nil)
            state.events.append(event)
            state.eventWriting.drafts[localIdentifier] = draft
            return event.reference
        }
    }

    func updateEvent(
        _ reference: CalendarItemReference,
        with draft: EventDraft,
        span: EventEditSpan
    ) async throws -> CalendarItemReference {
        try state.withLock { state in
            state.eventWriting.calls.append(.update(reference, draft, span))
            guard let edited = state.events.first(where: { Self.isOccurrence($0, of: reference) }) else {
                throw CalendarDataSourceError.itemNotFound
            }
            let shift = draft.startDate.timeIntervalSince(edited.startDate)
            state.events = state.events.map { event in
                guard Self.isAffected(event, by: reference, span: span) else { return event }
                var occurrenceDraft = draft
                occurrenceDraft.startDate = event.startDate.addingTimeInterval(shift)
                occurrenceDraft.endDate = occurrenceDraft.startDate.addingTimeInterval(draft.duration)
                return Self.event(
                    from: occurrenceDraft,
                    localIdentifier: event.reference.localIdentifier,
                    occurrenceDate: event.reference.occurrenceDate
                )
            }
            return reference
        }
    }

    func deleteEvent(_ reference: CalendarItemReference, span: EventEditSpan) async throws {
        state.withLock { state in
            state.eventWriting.calls.append(.delete(reference, span))
            state.events.removeAll { Self.isAffected($0, by: reference, span: span) }
        }
    }

    private static func isOccurrence(_ event: CalendarEvent, of reference: CalendarItemReference) -> Bool {
        event.reference.localIdentifier == reference.localIdentifier
            && event.reference.occurrenceDate == reference.occurrenceDate
    }

    private static func isAffected(
        _ event: CalendarEvent,
        by reference: CalendarItemReference,
        span: EventEditSpan
    ) -> Bool {
        guard span != .thisEvent,
              event.reference.localIdentifier == reference.localIdentifier,
              let occurrenceDate = event.reference.occurrenceDate,
              let editedOccurrenceDate = reference.occurrenceDate else {
            return isOccurrence(event, of: reference)
        }
        return occurrenceDate >= editedOccurrenceDate
    }

    static func event(from draft: EventDraft, localIdentifier: String, occurrenceDate: Date?) -> CalendarEvent {
        CalendarEvent(
            reference: CalendarItemReference(
                externalIdentifier: "external-\(localIdentifier)",
                localIdentifier: localIdentifier,
                calendarIdentifier: draft.calendarIdentifier,
                occurrenceDate: occurrenceDate,
                title: draft.title,
                startDate: draft.startDate
            ),
            calendarIdentifier: draft.calendarIdentifier,
            title: draft.title,
            location: draft.location?.text,
            notes: draft.notes,
            url: draft.url,
            startDate: draft.startDate,
            endDate: draft.endDate,
            isAllDay: draft.isAllDay,
            timeZone: draft.timeZone,
            isRecurring: occurrenceDate != nil || draft.recurrence != nil
        )
    }
}
