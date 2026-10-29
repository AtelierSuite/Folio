import Foundation

public enum NotificationResponseOutcome: Sendable, Hashable {
    case open(NotificationRoute)
    case snooze(NotificationSnooze)
    case markDone(NotificationItem)
}
