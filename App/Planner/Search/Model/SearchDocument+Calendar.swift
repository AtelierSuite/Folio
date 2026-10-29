import Foundation

extension SearchDocument {
    public init(event: CalendarEvent) {
        self.init(
            id: "event:\(event.id)",
            kind: .event,
            title: event.title,
            detail: event.location.flatMap { $0.isEmpty ? nil : $0 },
            body: event.notes ?? "",
            date: event.startDate,
            endDate: event.endDate,
            isAllDay: event.isAllDay,
            containerIdentifier: event.calendarIdentifier,
            color: event.color,
            hasMeetingLink: MeetingLink.isPresent(in: [event.location, event.notes], url: event.url),
            destination: .calendarDay(event.startDate, item: event.reference)
        )
    }

    public init(reminder: ReminderItem) {
        let date = reminder.dueDate ?? (reminder.isCompleted ? reminder.completionDate : nil)
        self.init(
            id: "reminder:\(reminder.id)",
            kind: .reminder,
            title: reminder.title,
            body: reminder.notes ?? "",
            date: date,
            isAllDay: reminder.dueDate != nil && !reminder.hasDueTime,
            isCompleted: reminder.isCompleted,
            containerIdentifier: reminder.listIdentifier,
            color: reminder.color,
            hasMeetingLink: MeetingLink.isPresent(in: [reminder.notes], url: reminder.url),
            destination: .calendarDay(date ?? .now, item: reminder.reference)
        )
    }
}
