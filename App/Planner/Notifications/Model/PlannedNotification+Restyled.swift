import Foundation

extension PlannedNotification {
    public var candidate: NotificationCandidate {
        NotificationCandidate(
            fireDate: fireDate, kind: kind, reference: reference, content: content, meeting: meeting, place: place
        )
    }

    public func restyled(_ style: NotificationAlertStyle) -> PlannedNotification {
        style == self.style ? self : PlannedNotification(candidate, style: style)
    }
}
