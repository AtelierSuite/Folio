import Foundation

extension NotificationScheduler {
    public func setEarlyAlerts(_ alerts: [ReminderEarlyAlert], for reference: CalendarItemReference) async {
        earlyAlertSettings.setAlerts(alerts, for: reference)
        await replan()
    }
}
