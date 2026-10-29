import Foundation

extension UndoCoordinator {
    /// Hides the event (or the occurrences in `span`) and deletes it once the toast expires.
    public func deleteEvent(_ event: CalendarEvent, span: EventEditSpan = .thisEvent) async throws {
        guard !event.isReadOnly else { throw EventEditingError.readOnly }
        await beginAction()
        let removalSpan: EventEditSpan = event.isRecurring ? span : .thisEvent
        let removal = PendingRemoval.event(
            localIdentifier: event.reference.localIdentifier,
            occurrenceDate: event.reference.occurrenceDate,
            span: removalSpan
        )
        record(stage(DeferredChange(
            action: .delete(.event),
            stage: { [store] in store.hide(removal) },
            unstage: { [store] in store.clearPendingChange($0) },
            commit: { [store] in try await store.deleteEvent(event, span: removalSpan) }
        )))
    }

    /// Saves an edit and registers it for undo. Use `.move(.event)` as the action for drags.
    /// "This and future events" edits split the series, which saving the old values can't
    /// join back, so those are previewed and only saved once the toast expires.
    @discardableResult
    public func updateEvent(
        _ event: CalendarEvent,
        with draft: EventDraft,
        span: EventEditSpan = .thisEvent,
        action: UndoAction = .edit(.event)
    ) async throws -> CalendarItemReference {
        guard !event.isReadOnly else { throw EventEditingError.readOnly }
        try store.validate(draft)
        await beginAction()
        guard event.isRecurring && span != .thisEvent else {
            return try await updateOccurrence(event, with: draft, action: action)
        }
        let firstOccurrence = try await store.source.firstOccurrence(of: event.reference)
        if span == .futureEvents && firstOccurrence.reference.occurrenceDate != event.reference.occurrenceDate {
            holdSeriesEdit(of: event, with: draft, action: action)
            return event.reference
        }
        return try await updateSeries(of: event, from: firstOccurrence, with: draft, action: action)
    }

    private func holdSeriesEdit(of event: CalendarEvent, with draft: EventDraft, action: UndoAction) {
        let edit = PendingEventEdit(event: event, draft: draft)
        record(stage(DeferredChange(
            action: action,
            stage: { [store] in store.hold(edit) },
            unstage: { [store] in store.clearPendingChange($0) },
            commit: { [store] in try await store.updateEvent(event, with: draft, span: .futureEvents) }
        )))
    }

    private func updateOccurrence(
        _ event: CalendarEvent,
        with draft: EventDraft,
        action: UndoAction
    ) async throws -> CalendarItemReference {
        let originalDraft = try await store.eventDraft(for: event)
        let reference = try await store.saveEvent(at: event.reference, with: draft, span: .thisEvent)
        recordEventChange(action, at: reference, from: originalDraft, to: draft, span: .thisEvent)
        return reference
    }

    private func updateSeries(
        of event: CalendarEvent,
        from firstOccurrence: CalendarEvent,
        with draft: EventDraft,
        action: UndoAction
    ) async throws -> CalendarItemReference {
        let originalDraft = try await store.source.eventDraft(for: firstOccurrence.reference)
        let seriesDraft = draft.appliedToSeries(
            editedOccurrenceStart: event.startDate,
            firstOccurrenceStart: firstOccurrence.startDate
        )
        let reference = try await store.saveEvent(at: firstOccurrence.reference, with: seriesDraft, span: .futureEvents)
        recordEventChange(action, at: reference, from: originalDraft, to: seriesDraft, span: .futureEvents)
        return reference
    }

    private func recordEventChange(
        _ action: UndoAction,
        at reference: CalendarItemReference,
        from originalDraft: EventDraft,
        to draft: EventDraft,
        span: EventEditSpan
    ) {
        let saved = SavedEventReference(reference)
        record(.reversible(
            action,
            undo: { [store] in
                saved.reference = try await store.saveEvent(at: saved.reference, with: originalDraft, span: span)
            },
            redo: { [store] in
                saved.reference = try await store.saveEvent(at: saved.reference, with: draft, span: span)
            }
        ))
    }
}

/// Saving can move an occurrence, so undo and redo look the event up by its latest reference.
@MainActor
private final class SavedEventReference {
    var reference: CalendarItemReference

    init(_ reference: CalendarItemReference) {
        self.reference = reference
    }
}
