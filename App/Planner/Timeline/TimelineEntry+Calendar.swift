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
            hasLink: event.url != nil,
            meetingLink: event.meetingLink
        )
    }

    public static func reminderIdentifier(for reminder: ReminderItem) -> String {
        "reminder:\(reminder.id)"
    }

    /// Carried forward reminders go in today's all-day strip, whatever time they were due.
    public init?(reminder: ReminderItem, calendar: Calendar = .current) {
        guard let scheduledDate = reminder.scheduledDate else { return nil }
        let isTimed = reminder.hasDueTime && !reminder.isCarriedForward
        let start = isTimed ? scheduledDate : calendar.startOfDay(for: scheduledDate)
        let end = isTimed
            ? scheduledDate.addingTimeInterval(Self.reminderDuration)
            : calendar.date(byAdding: .day, value: 1, to: start) ?? start
        self.init(
            id: Self.reminderIdentifier(for: reminder),
            title: reminder.title,
            start: start,
            end: end,
            isAllDay: !isTimed,
            timeZone: nil,
            color: TimelineColor(reminder.color),
            isReadOnly: reminder.isReadOnly,
            kind: .reminder,
            isCompleted: reminder.isCompleted,
            isOverdue: reminder.isCarriedForward && !reminder.isCompleted
        )
    }
}

extension TimelineColor {
    public init(_ color: PlannerColor) {
        self.init(red: color.red, green: color.green, blue: color.blue)
    }
}
