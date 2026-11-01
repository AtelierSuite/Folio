import Foundation

extension WakeUpAlarm {
    func request(formatter: NotificationContentFormatter) -> AlarmRequest {
        AlarmRequest(
            id: AlarmIdentifier.make(fromNotificationIdentifier: id),
            fireDate: fireDate,
            title: formatter.wakeUpTitle(for: self),
            tint: nil,
            item: NotificationItem(kind: .event, reference: event.reference, fireDate: fireDate),
            secondaryAction: .snooze(WakeUpAlarmPlanner.snoozeDuration)
        )
    }
}

extension NotificationContentFormatter {
    public func wakeUpTitle(for alarm: WakeUpAlarm) -> String {
        String(
            format: String(localized: "Alarm.Title", table: "WakeUpAlarms", bundle: #bundle),
            alarm.event.title,
            time(of: alarm.event.startDate, firingAt: alarm.fireDate)
        )
    }
}
