import Foundation

public struct NoteLinkEvent: Hashable, Sendable {
    public let eventKey: String
    public let calendarIdentifier: String
    public let title: String
    public let dayKey: String

    public init(eventKey: String, calendarIdentifier: String, title: String, dayKey: String) {
        self.eventKey = eventKey
        self.calendarIdentifier = calendarIdentifier
        self.title = title
        self.dayKey = dayKey
    }

    public init(event: CalendarEvent, timeZone: TimeZone = .current) {
        self.init(
            eventKey: event.reference.storageKey,
            calendarIdentifier: event.calendarIdentifier,
            title: event.title,
            dayKey: DailyNoteNaming.dayKey(for: event.startDate, timeZone: timeZone)
        )
    }

    /// Also matches a link made before the event's identifiers changed, as `LinkedNoteIndex` does.
    public func matches(_ event: CalendarEvent) -> Bool {
        let reference = event.reference
        if eventKey == reference.storageKey {
            return true
        }
        guard let linked = CalendarItemReference(storageKey: eventKey) else { return false }
        return reference.bestMatch(in: [linked]) != nil
    }
}

public struct NoteLink: Hashable, Sendable {
    public let notePath: String
    public let event: NoteLinkEvent
    public let linkedAt: Date
}
