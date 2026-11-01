import Foundation

public struct NotificationSnoozeSettings: @unchecked Sendable {
    public static let shortMinutesKey = "Notifications.Snooze.ShortMinutes"
    public static let longMinutesKey = "Notifications.Snooze.LongMinutes"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public var durations: NotificationSnoozeDurations {
        get {
            NotificationSnoozeDurations(
                shortMinutes: defaults.object(forKey: Self.shortMinutesKey) as? Int
                    ?? NotificationSnoozeDurations.standard.shortMinutes,
                longMinutes: defaults.object(forKey: Self.longMinutesKey) as? Int
                    ?? NotificationSnoozeDurations.standard.longMinutes
            )
        }
        nonmutating set {
            defaults.set(newValue.shortMinutes, forKey: Self.shortMinutesKey)
            defaults.set(newValue.longMinutes, forKey: Self.longMinutesKey)
        }
    }
}
