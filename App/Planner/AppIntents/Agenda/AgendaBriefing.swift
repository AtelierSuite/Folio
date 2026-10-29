import Foundation

/// What "What's next?" and "What's on my calendar today?" answer with: the items to show and what Siri says.
public struct AgendaBriefing: Sendable, Equatable {
    public let events: [CalendarEvent]
    public let reminders: [ReminderItem]
    public let dialog: String

    public init(events: [CalendarEvent], reminders: [ReminderItem] = [], dialog: String) {
        self.events = events
        self.reminders = reminders
        self.dialog = dialog
    }
}
