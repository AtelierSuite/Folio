import Foundation

/// AlarmKit shows Stop plus at most one more button, so each alarm picks the one that suits it.
public enum AlarmSecondaryAction: Sendable, Hashable, Codable {
    case snooze(TimeInterval)
    case open

    public static var alertSnooze: AlarmSecondaryAction {
        let durations = NotificationSnoozeSettings().durations
        return .snooze(NotificationAction.snoozeShort.snoozeDuration(in: durations) ?? 300)
    }
}
