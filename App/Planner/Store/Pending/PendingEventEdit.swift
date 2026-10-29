import Foundation

/// A "this and future events" edit held until the undo toast expires, previewed on the
/// occurrences it will change so the calendar already shows the edit.
public struct PendingEventEdit: Sendable, Hashable {
    public let localIdentifier: String
    public let occurrenceDate: Date?
    public let editedStartDate: Date
    public let draft: EventDraft

    public init(event: CalendarEvent, draft: EventDraft) {
        localIdentifier = event.reference.localIdentifier
        occurrenceDate = event.reference.occurrenceDate
        editedStartDate = event.startDate
        self.draft = draft
    }

    public func covers(_ event: CalendarEvent) -> Bool {
        guard event.reference.localIdentifier == localIdentifier else { return false }
        guard let occurrenceDate, let candidateDate = event.reference.occurrenceDate else { return true }
        return candidateDate >= occurrenceDate
    }

    func preview(of event: CalendarEvent, color: PlannerColor?) -> CalendarEvent {
        let startDate = event.startDate.addingTimeInterval(draft.startDate.timeIntervalSince(editedStartDate))
        return CalendarEvent(
            reference: event.reference,
            calendarIdentifier: draft.calendarIdentifier,
            title: draft.title,
            location: draft.location?.text,
            notes: draft.notes.isEmpty ? nil : draft.notes,
            url: draft.url,
            startDate: startDate,
            endDate: startDate.addingTimeInterval(draft.duration),
            isAllDay: draft.isAllDay,
            timeZone: draft.savedTimeZone,
            color: color ?? event.color,
            isRecurring: event.isRecurring,
            hasAttendees: event.hasAttendees,
            isReadOnly: event.isReadOnly,
            alarms: event.alarms
        )
    }

    func draft(for previewedEvent: CalendarEvent) -> EventDraft {
        var occurrenceDraft = draft
        occurrenceDraft.startDate = previewedEvent.startDate
        occurrenceDraft.endDate = previewedEvent.endDate
        return occurrenceDraft
    }
}
