import Foundation

extension WidgetSnapshot {
    /// Today's all-day events, then the timed events that haven't ended yet.
    public func todayEvents(at date: Date, calendar: Calendar) -> [CalendarEvent] {
        guard let today = calendar.dateInterval(of: .day, for: date) else { return [] }
        let todays = events.filter { $0.overlaps(today) }
        let allDay = todays.filter(\.isAllDay)
        let timed = todays.filter { !$0.isAllDay && $0.endDate > date }
        return allDay + timed
    }

    /// Reminders due today, including overdue ones, earliest first.
    public func todayReminders(at date: Date, calendar: Calendar) -> [ReminderItem] {
        guard let today = calendar.dateInterval(of: .day, for: date) else { return [] }
        return reminders
            .filter { reminder in reminder.dueDate.map { $0 < today.end } ?? false }
            .sorted(by: Self.isOrderedBefore)
    }

    /// Open reminders, dated ones first by due date, then undated ones by priority and title.
    public func checklist(limit: Int) -> [ReminderItem] {
        Array(reminders.sorted(by: Self.isOrderedBefore).prefix(limit))
    }

    public func remainingReminderCount(at date: Date, calendar: Calendar) -> Int {
        todayReminders(at: date, calendar: calendar).count
    }

    static func isOrderedBefore(_ first: ReminderItem, _ second: ReminderItem) -> Bool {
        switch (first.dueDate, second.dueDate) {
        case let (.some(firstDue), .some(secondDue)) where firstDue != secondDue:
            return firstDue < secondDue
        case (.some, .none):
            return true
        case (.none, .some):
            return false
        default:
            let firstPriority = first.priority == 0 ? Int.max : first.priority
            let secondPriority = second.priority == 0 ? Int.max : second.priority
            return (firstPriority, first.title.localizedLowercase) < (secondPriority, second.title.localizedLowercase)
        }
    }
}
