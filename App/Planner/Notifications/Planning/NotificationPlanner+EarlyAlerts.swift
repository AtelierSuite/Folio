import Foundation

extension NotificationPlanner {
    func earlyAlertFireDates(for reminder: ReminderItem, after now: Date) -> [Date] {
        guard let anchor = earlyAlertAnchor(for: reminder) else { return [] }
        return reminderEarlyAlerts(reminder.reference)
            .compactMap { $0.fireDate(before: anchor, in: formatter.calendar) }
            .filter { $0 > now }
    }

    private func earlyAlertAnchor(for reminder: ReminderItem) -> Date? {
        guard let dueDate = reminder.dueDate else { return nil }
        guard !reminder.hasDueTime, let minutes = allDayAlertMinutes(reminder.listIdentifier) else { return dueDate }
        return formatter.calendar.date(
            byAdding: .minute, value: minutes, to: formatter.calendar.startOfDay(for: dueDate)
        )
    }
}
