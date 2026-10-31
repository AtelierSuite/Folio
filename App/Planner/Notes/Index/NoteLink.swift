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
}

public struct NoteLink: Hashable, Sendable {
    public let notePath: String
    public let event: NoteLinkEvent
    public let linkedAt: Date
}
