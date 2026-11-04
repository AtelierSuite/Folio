import Foundation

extension NotificationPlanner {
    /// Copies can start up to 30 minutes apart, so alerts with the same lead time are one alert even
    /// though they fire at different moments. An alarm set on only one copy still fires.
    func eventNotifications(
        _ events: [CalendarEvent],
        after now: Date,
        images: [CalendarItemReference: URL]
    ) -> [PlannedNotification] {
        EventDuplicateDetector(calendar: formatter.calendar).groups(in: events).flatMap { group in
            let alerts = group.events.flatMap { event in
                eventCandidates([event], after: now, images: images).map { candidate in
                    LeadTimedAlert(
                        leadTime: event.startDate.timeIntervalSince(candidate.fireDate),
                        notification: planned(candidate)
                    )
                }
            }
            return loudest(among: loudest(among: alerts, by: \.leadTime), by: \.notification.fireDate)
                .map(\.notification)
        }
    }

    func reminderNotifications(_ reminders: [ReminderItem], after now: Date) -> [PlannedNotification] {
        let excludedLists = DuplicateDetectionSettings.shared.excludedCalendarIdentifiers
        let alerts = reminderCandidates(reminders, after: now)
            .map { LeadTimedAlert(leadTime: 0, notification: planned($0)) }
            .sorted { $0.notification.id < $1.notification.id }
        return Dictionary(grouping: alerts) { alert in
            let reference = alert.notification.reference
            return excludedLists.contains(reference.calendarIdentifier)
                ? reference.storageKey
                : DuplicateText.comparisonKey(reference.title) ?? reference.storageKey
        }
        .values
        .flatMap { loudest(among: $0, by: \.notification.fireDate).map(\.notification) }
    }

    private func planned(_ candidate: NotificationCandidate) -> PlannedNotification {
        PlannedNotification(candidate, style: styleResolver(candidate), sound: soundResolver(candidate))
    }

    /// The first alert for a key wins unless a later one is set to a louder style, which would otherwise go unheard.
    private func loudest<Key: Hashable>(
        among alerts: [LeadTimedAlert],
        by key: (LeadTimedAlert) -> Key
    ) -> [LeadTimedAlert] {
        var kept: [LeadTimedAlert] = []
        var indexes: [Key: Int] = [:]
        for alert in alerts {
            guard let index = indexes[key(alert)] else {
                indexes[key(alert)] = kept.count
                kept.append(alert)
                continue
            }
            if alert.notification.style.urgency > kept[index].notification.style.urgency {
                kept[index] = alert
            }
        }
        return kept
    }
}

private struct LeadTimedAlert {
    let leadTime: TimeInterval
    let notification: PlannedNotification
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
