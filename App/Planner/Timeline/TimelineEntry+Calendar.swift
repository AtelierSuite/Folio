import Foundation

extension TimelineEntry {
    public static let reminderDuration: TimeInterval = 30 * 60

    public init(event: CalendarEvent) {
        self.init(
            id: event.id,
            title: event.title,
            start: event.startDate,
            end: event.endDate,
            isAllDay: event.isAllDay,
            timeZone: event.isAllDay ? nil : event.timeZone,
            color: TimelineColor(event.color),
            isReadOnly: event.isReadOnly,
            kind: .event,
            location: event.location.flatMap { $0.isEmpty ? nil : $0 },
            hasLink: event.url != nil
        )
    }

    public init?(reminder: ReminderItem, calendar: Calendar = .current) {
        guard let dueDate = reminder.dueDate else { return nil }
        let start = reminder.hasDueTime ? dueDate : calendar.startOfDay(for: dueDate)
        let end = reminder.hasDueTime
            ? dueDate.addingTimeInterval(Self.reminderDuration)
            : calendar.date(byAdding: .day, value: 1, to: start) ?? start
        self.init(
            id: "reminder:\(reminder.id)",
            title: reminder.title,
            start: start,
            end: end,
            isAllDay: !reminder.hasDueTime,
            timeZone: nil,
            color: TimelineColor(reminder.color),
            isReadOnly: reminder.isReadOnly,
            kind: .reminder
        )
    }
}

extension TimelineColor {
    public init(_ color: PlannerColor) {
        self.init(red: color.red, green: color.green, blue: color.blue)
    }
}
