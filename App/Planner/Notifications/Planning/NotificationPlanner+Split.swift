import Foundation

extension NotificationPlanner {
    public static let alarmLimit = 32

    public func plan(
        events: [CalendarEvent],
        reminders: [ReminderItem],
        after now: Date,
        budget: Int,
        alarmBudget: Int?
    ) -> NotificationPlan {
        let everything = plan(events: events, reminders: reminders, after: now, budget: .max)
            .map { alarmBudget != nil || $0.style != .alarm ? $0 : $0.restyled(.timeSensitive) }
            .sorted { ($0.fireDate, $0.id) < ($1.fireDate, $1.id) }
        let alarms = everything.filter { $0.style == .alarm }
        let notifications = everything.filter { $0.style != .alarm }
        return NotificationPlan(
            notifications: Array(notifications.prefix(max(0, budget))),
            alarms: Array(alarms.prefix(max(0, alarmBudget ?? 0)))
        )
    }
}
