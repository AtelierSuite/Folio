import Foundation
import UserNotifications

public struct UserNotificationLeaveAlertScheduler: LeaveAlertScheduling {
    private let formatter: NotificationContentFormatter

    public init(formatter: NotificationContentFormatter = NotificationContentFormatter()) {
        self.formatter = formatter
    }

    private var center: UNUserNotificationCenter {
        .current()
    }

    public func pendingIdentifiers() async -> [String] {
        await center.pendingNotificationRequests()
            .map(\.identifier)
            .filter { $0.hasPrefix(LeaveAlert.identifierPrefix) }
    }

    public func schedule(_ alert: LeaveAlert, now: Date) async {
        let event = alert.event
        let planned = PlannedNotification(NotificationCandidate(
            fireDate: alert.fireDate,
            kind: .event,
            reference: event.reference,
            content: formatter.leaveContent(for: alert),
            place: NotificationPlace(name: event.location, coordinate: alert.destination)
        ), style: .timeSensitive)
        let interval = max(1, alert.fireDate.timeIntervalSince(now))
        let request = UNNotificationRequest(
            identifier: alert.id,
            content: UNNotificationContent.make(planned),
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        )
        try? await center.add(request)
    }

    public func removePending(withIdentifiers identifiers: [String]) async {
        guard !identifiers.isEmpty else { return }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
