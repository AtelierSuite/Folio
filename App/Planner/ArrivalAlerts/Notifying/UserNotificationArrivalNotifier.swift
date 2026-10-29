import Foundation
import UserNotifications

public struct UserNotificationArrivalNotifier: ArrivalNotifying {
    private let formatter: NotificationContentFormatter

    public init(formatter: NotificationContentFormatter = NotificationContentFormatter()) {
        self.formatter = formatter
    }

    public func notify(_ candidate: ArrivalCandidate, at date: Date) async {
        let event = candidate.event
        let planned = PlannedNotification(NotificationCandidate(
            fireDate: date,
            kind: .event,
            reference: event.reference,
            content: formatter.arrivalContent(for: event, at: date)
        ))
        let request = UNNotificationRequest(
            identifier: "\(ArrivalRegion.identifierPrefix)\(event.id)",
            content: UNNotificationContent.make(planned),
            trigger: nil
        )
        try? await UNUserNotificationCenter.current().add(request)
    }
}
