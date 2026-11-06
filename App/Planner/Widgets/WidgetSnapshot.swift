import Foundation

/// The calendar data one widget timeline is built from.
public struct WidgetSnapshot: Sendable, Hashable {
    public var eventAuthorization: CalendarAuthorizationStatus
    public var reminderAuthorization: CalendarAuthorizationStatus
    public var events: [CalendarEvent]
    public var reminders: [ReminderItem]
    /// Cached daily weather keyed by the start of each day.
    public var weather: [Date: DailyWeather]
    public var alarmDates: [Date]
    /// Today's doses still waiting on the user, read from Health for this snapshot and never stored.
    public var medicationDoses: [MedicationDose]
    /// Note digests keyed by the storage key of the event they're linked to.
    public var eventNotes: [String: EventNoteDigest]
    /// Attendee badges keyed by participant identifier.
    public var contactBadges: [String: ContactBadge]

    public init(
        eventAuthorization: CalendarAuthorizationStatus = .fullAccess,
        reminderAuthorization: CalendarAuthorizationStatus = .fullAccess,
        events: [CalendarEvent] = [],
        reminders: [ReminderItem] = [],
        weather: [Date: DailyWeather] = [:],
        alarmDates: [Date] = [],
        medicationDoses: [MedicationDose] = [],
        eventNotes: [String: EventNoteDigest] = [:],
        contactBadges: [String: ContactBadge] = [:]
    ) {
        self.eventAuthorization = eventAuthorization
        self.reminderAuthorization = reminderAuthorization
        self.events = events.sorted { ($0.startDate, $0.title) < ($1.startDate, $1.title) }
        self.reminders = reminders.filter { !$0.isCompleted }
        self.weather = weather
        self.alarmDates = alarmDates.sorted()
        self.medicationDoses = medicationDoses
        self.eventNotes = eventNotes
        self.contactBadges = contactBadges
    }

    public func weather(on date: Date, calendar: Calendar) -> DailyWeather? {
        weather[calendar.startOfDay(for: date)]
    }

    public var canReadEvents: Bool {
        eventAuthorization.allowsReading
    }

    public var canReadReminders: Bool {
        reminderAuthorization.allowsReading
    }
}
