import Foundation

extension NotificationPlanner {
    public static let alarmLimit = 32

    public func plan(
        events: [CalendarEvent],
        reminders: [ReminderItem],
        after now: Date,
        budget: Int,
        alarmBudget: Int?,
        eventImages: [CalendarItemReference: URL] = [:]
    ) -> NotificationPlan {
        let everything = plan(events: events, reminders: reminders, after: now, budget: .max, eventImages: eventImages)
            .map { alarmBudget != nil || $0.style != .alarm ? $0 : $0.restyled(.timeSensitive) }
            .sorted { ($0.fireDate, $0.id) < ($1.fireDate, $1.id) }
        let allAlarms = everything.filter { $0.style == .alarm }
        let alarms = Array(allAlarms.prefix(max(0, alarmBudget ?? 0)))
        let overflow = allAlarms.dropFirst(alarms.count).map { $0.restyled(.timeSensitive) }
        let notifications = (everything.filter { $0.style != .alarm } + overflow)
            .sorted { ($0.fireDate, $0.id) < ($1.fireDate, $1.id) }
        return NotificationPlan(
            notifications: Array(notifications.prefix(max(0, budget))),
            alarms: alarms
        )
    }
}
