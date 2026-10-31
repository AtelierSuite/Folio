import Foundation

extension CalendarStore {
    /// Only fills an empty URL field of an event that can be edited; returns whether it wrote the link.
    @discardableResult
    public func addNoteLink(_ link: URL, to event: CalendarEvent) async throws -> Bool {
        guard canEditURL(of: event), event.url == nil else {
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

    /// Clears the event's URL only while it is still a `folio://` link, so a URL the user put there stays.
    @discardableResult
    public func removeNoteLink(from event: CalendarEvent) async throws -> Bool {
        guard canEditURL(of: event), event.url?.scheme?.lowercased() == NoteDeepLink.scheme else {
            return false
        }
        var draft = try await eventDraft(for: event)
        guard draft.url?.scheme?.lowercased() == NoteDeepLink.scheme else {
            return false
        }
        draft.url = nil
        try await updateEvent(event, with: draft, span: .thisEvent)
        return true
    }

    public func containsEvent(matching reference: CalendarItemReference) async -> Bool? {
        guard eventAuthorization.allowsReading else { return nil }
        return await source.containsEvent(matching: reference)
    }

    private func canEditURL(of event: CalendarEvent) -> Bool {
        !event.isReadOnly
            && eventCalendars.contains { $0.id == event.calendarIdentifier && !$0.isReadOnly }
    }
}
