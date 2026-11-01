import Foundation

extension PlannedNotification {
    public var candidate: NotificationCandidate {
        NotificationCandidate(
            fireDate: fireDate,
            kind: kind,
            reference: reference,
            content: content,
            meeting: meeting,
            place: place,
            color: color,
            imageURL: imageURL
        )
    }

    public func restyled(_ style: NotificationAlertStyle) -> PlannedNotification {
        style == self.style ? self : PlannedNotification(candidate, style: style, sound: sound)
    }
}
