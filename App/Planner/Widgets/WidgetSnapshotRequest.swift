import Foundation

/// What a widget needs loaded and how often its timeline changes.
public struct WidgetSnapshotRequest: Sendable, Hashable {
    public var eventInterval: DateInterval?
    public var calendars: Set<String>?
    public var includesReminders: Bool
    public var lists: Set<String>?

    public init(
        eventInterval: DateInterval?,
        calendars: Set<String>? = nil,
        includesReminders: Bool = false,
        lists: Set<String>? = nil
    ) {
        self.eventInterval = eventInterval
        self.calendars = calendars
        self.includesReminders = includesReminders
        self.lists = lists
    }

    /// Today and tomorrow, enough for Up Next and the agenda to roll over at midnight.
    public static func upcoming(
        from now: Date,
        calendar: Calendar,
        calendars: Set<String>? = nil,
        includesReminders: Bool = false,
        lists: Set<String>? = nil
    ) -> WidgetSnapshotRequest {
        WidgetSnapshotRequest(
            eventInterval: days(from: now, count: 2, calendar: calendar),
            calendars: calendars,
            includesReminders: includesReminders,
            lists: lists
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

    public static func reminders(lists: Set<String>? = nil) -> WidgetSnapshotRequest {
        WidgetSnapshotRequest(eventInterval: nil, includesReminders: true, lists: lists)
    }

    static func days(from now: Date, count: Int, calendar: Calendar) -> DateInterval {
        let start = calendar.startOfDay(for: now)
        let end = calendar.date(byAdding: .day, value: count, to: start)
            ?? start.addingTimeInterval(Double(count) * 86_400)
        return DateInterval(start: start, end: end)
    }
}
