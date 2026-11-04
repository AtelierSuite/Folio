import Foundation

extension NotificationPlanner {
    /// Copies of an event share one alert per moment, so alarms set on only one copy still fire.
    func eventNotifications(
        _ events: [CalendarEvent],
        after now: Date,
        images: [CalendarItemReference: URL]
    ) -> [PlannedNotification] {
        EventDuplicateDetector(calendar: formatter.calendar).groups(in: events).flatMap { group in
            oneNotificationPerMoment(from: eventCandidates(group.events, after: now, images: images).map(planned))
        }
    }

    func reminderNotifications(_ reminders: [ReminderItem], after now: Date) -> [PlannedNotification] {
        let notifications = reminderCandidates(reminders, after: now).map(planned).sorted { $0.id < $1.id }
        return Dictionary(grouping: notifications) { notification in
            DuplicateText.titleKey(notification.reference.title) ?? notification.reference.storageKey
        }
        .values
        .flatMap { oneNotificationPerMoment(from: $0) }
    }

    private func planned(_ candidate: NotificationCandidate) -> PlannedNotification {
        PlannedNotification(candidate, style: styleResolver(candidate), sound: soundResolver(candidate))
    }

    /// The earliest listed copy wins unless another is set to a louder style, which would otherwise go unheard.
    private func oneNotificationPerMoment(from notifications: [PlannedNotification]) -> [PlannedNotification] {
        var chosen: [Date: PlannedNotification] = [:]
        for notification in notifications {
            guard let current = chosen[notification.fireDate] else {
                chosen[notification.fireDate] = notification
                continue
            }
            if notification.style.urgency > current.style.urgency {
                chosen[notification.fireDate] = notification
            }
        }
        return Array(chosen.values)
    }
}

private extension NotificationAlertStyle {
    var urgency: Int {
        switch self {
        case .standard: 0
        case .timeSensitive: 1
        case .alarm: 2
        }
    }
}
