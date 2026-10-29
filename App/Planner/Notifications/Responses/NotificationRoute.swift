import Foundation

/// Where Folio goes after an alert or one of its actions brings it to the foreground.
public enum NotificationRoute: Sendable, Hashable {
    case item(AppDestination, meetingURL: URL?)
    case url(URL)
    case note(NotificationNoteTarget)
}

public enum NotificationNoteTarget: Sendable, Hashable {
    case event(CalendarItemReference, date: Date)
    case dailyNote(Date)
}
