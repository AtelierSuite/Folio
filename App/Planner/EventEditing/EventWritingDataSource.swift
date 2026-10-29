import Foundation

public protocol EventWritingDataSource: Sendable {
    func defaultEventCalendarIdentifier() -> String?
    func eventDraft(for reference: CalendarItemReference) async throws -> EventDraft
    func firstOccurrence(of reference: CalendarItemReference) async throws -> CalendarEvent
    func createEvent(_ draft: EventDraft) async throws -> CalendarItemReference
    func updateEvent(
        _ reference: CalendarItemReference,
        with draft: EventDraft,
        span: EventEditSpan
    ) async throws -> CalendarItemReference
    func deleteEvent(_ reference: CalendarItemReference, span: EventEditSpan) async throws
}
