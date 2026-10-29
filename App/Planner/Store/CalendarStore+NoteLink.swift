import Foundation

extension CalendarStore {
    /// Only fills an empty URL field of an event that can be edited; returns whether it wrote the link.
    @discardableResult
    public func addNoteLink(_ link: URL, to event: CalendarEvent) async throws -> Bool {
        guard !event.isReadOnly, event.url == nil,
              eventCalendars.contains(where: { $0.id == event.calendarIdentifier && !$0.isReadOnly }) else {
            return false
        }
        var draft = try await eventDraft(for: event)
        guard draft.url == nil else {
            return false
        }
        draft.url = link
        try await updateEvent(event, with: draft, span: .thisEvent)
        return true
    }
}
