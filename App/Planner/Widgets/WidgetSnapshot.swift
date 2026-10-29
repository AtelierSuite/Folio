import Foundation

/// The calendar data one widget timeline is built from.
public struct WidgetSnapshot: Sendable, Hashable {
    public var eventAuthorization: CalendarAuthorizationStatus
    public var reminderAuthorization: CalendarAuthorizationStatus
    public var events: [CalendarEvent]
    public var reminders: [ReminderItem]

    public init(
        eventAuthorization: CalendarAuthorizationStatus = .fullAccess,
        reminderAuthorization: CalendarAuthorizationStatus = .fullAccess,
        events: [CalendarEvent] = [],
        reminders: [ReminderItem] = []
    ) {
        self.eventAuthorization = eventAuthorization
        self.reminderAuthorization = reminderAuthorization
        self.events = events.sorted { ($0.startDate, $0.title) < ($1.startDate, $1.title) }
        self.reminders = reminders.filter { !$0.isCompleted }
    }

    public var canReadEvents: Bool {
        eventAuthorization.allowsReading
    }

    public var canReadReminders: Bool {
        reminderAuthorization.allowsReading
    }
}
