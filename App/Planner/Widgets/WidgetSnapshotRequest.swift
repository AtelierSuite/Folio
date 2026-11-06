import Foundation

/// What a widget needs loaded and how often its timeline changes.
public struct WidgetSnapshotRequest: Sendable, Hashable {
    public var eventInterval: DateInterval?
    public var calendars: Set<String>?
    public var includesReminders: Bool
    public var lists: Set<String>?
    public var includesWeather: Bool
    public var includesAlarms: Bool
    public var includesEventNotes: Bool
    public var includesMedications: Bool
    public var includesLeaveBy: Bool

    public init(
        eventInterval: DateInterval?,
        calendars: Set<String>? = nil,
        includesReminders: Bool = false,
        lists: Set<String>? = nil,
        includesWeather: Bool = false,
        includesAlarms: Bool = false,
        includesEventNotes: Bool = false,
        includesMedications: Bool = false,
        includesLeaveBy: Bool = false
    ) {
        self.eventInterval = eventInterval
        self.calendars = calendars
        self.includesReminders = includesReminders
        self.lists = lists
        self.includesWeather = includesWeather
        self.includesAlarms = includesAlarms
        self.includesEventNotes = includesEventNotes
        self.includesMedications = includesMedications
        self.includesLeaveBy = includesLeaveBy
    }

    /// Today and tomorrow, enough for Up Next and the agenda to roll over at midnight.
    public static func upcoming(
        from now: Date,
        calendar: Calendar,
        calendars: Set<String>? = nil,
        includesReminders: Bool = false,
        lists: Set<String>? = nil,
        includesWeather: Bool = false,
        includesAlarms: Bool = false,
        includesLeaveBy: Bool = false
    ) -> WidgetSnapshotRequest {
        WidgetSnapshotRequest(
            eventInterval: days(from: now, count: 2, calendar: calendar),
            calendars: calendars,
            includesReminders: includesReminders,
            lists: lists,
            includesWeather: includesWeather,
            includesAlarms: includesAlarms,
            includesLeaveBy: includesLeaveBy
        )
    }

    public static func month(
        containing now: Date,
        calendar: Calendar,
        calendars: Set<String>? = nil
    ) -> WidgetSnapshotRequest {
        let grid = MonthGrid(containing: now, calendar: calendar)
        return WidgetSnapshotRequest(
            eventInterval: grid.span ?? days(from: now, count: 1, calendar: calendar),
            calendars: calendars
        )
    }

    /// The days the app publishes note digests for.
    public static func eventNotes(
        from now: Date,
        calendar: Calendar,
        calendars: Set<String>? = nil
    ) -> WidgetSnapshotRequest {
        WidgetSnapshotRequest(
            eventInterval: days(from: now, count: EventNoteDigest.lookAheadDays, calendar: calendar),
            calendars: calendars,
            includesEventNotes: true
        )
    }

    /// A week of events, to find invitations and conflicts, with the reminders and doses due.
    public static func inbox(
        from now: Date,
        calendar: Calendar,
        calendars: Set<String>? = nil,
        lists: Set<String>? = nil,
        includesMedications: Bool
    ) -> WidgetSnapshotRequest {
        WidgetSnapshotRequest(
            eventInterval: days(from: now, count: inboxDays, calendar: calendar),
            calendars: calendars,
            includesReminders: true,
            lists: lists,
            includesMedications: includesMedications
        )
    }

    public static func reminders(lists: Set<String>? = nil) -> WidgetSnapshotRequest {
        WidgetSnapshotRequest(eventInterval: nil, includesReminders: true, lists: lists)
    }

    private static let inboxDays = 7

    static func days(from now: Date, count: Int, calendar: Calendar) -> DateInterval {
        let start = calendar.startOfDay(for: now)
        let end = calendar.date(byAdding: .day, value: count, to: start)
            ?? start.addingTimeInterval(Double(count) * 86_400)
        return DateInterval(start: start, end: end)
    }
}
