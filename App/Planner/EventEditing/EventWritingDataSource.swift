import Foundation

public protocol EventWritingDataSource: Sendable {
    func defaultEventCalendarIdentifier() -> String?
    @concurrent func eventDraft(for reference: CalendarItemReference) async throws -> EventDraft
    @concurrent func firstOccurrence(of reference: CalendarItemReference) async throws -> CalendarEvent
    @concurrent func createEvent(_ draft: EventDraft) async throws -> CalendarItemReference
    @concurrent func updateEvent(
        _ reference: CalendarItemReference,
        with draft: EventDraft,
        span: EventEditSpan
    ) async throws -> CalendarItemReference
    @concurrent func deleteEvent(_ reference: CalendarItemReference, span: EventEditSpan) async throws
}
