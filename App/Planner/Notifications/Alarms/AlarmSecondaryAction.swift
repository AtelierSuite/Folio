import Foundation

/// AlarmKit shows Stop plus at most one more button, so each alarm picks the one that suits it.
public enum AlarmSecondaryAction: Sendable, Hashable, Codable {
    case snooze(TimeInterval)
    case open

    public static var snooze: AlarmSecondaryAction {
        .snooze(AlarmSnoozeSettings().duration)
    }

    /// `nil` minutes falls back to the Snooze Time setting.
    public static func snooze(minutes: Int?) -> AlarmSecondaryAction {
        guard let minutes else { return snooze }
        return .snooze(TimeInterval(AlarmSnoozeSettings.clamped(minutes) * 60))
    }
}
