import Foundation

/// A place in the app that another feature (search, Spotlight, widgets, intents) can ask to open.
public enum AppDestination: Hashable, Sendable {
    case calendarDay(Date, item: CalendarItemReference? = nil)
    case note(URL)
    case newEvent
    case newReminder
    case newNote
}
