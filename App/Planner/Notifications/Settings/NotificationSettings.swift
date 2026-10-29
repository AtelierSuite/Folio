import Foundation

public struct NotificationSettings: @unchecked Sendable {
    public static let isEnabledKey = "Notifications.Enabled"
    public static let includesEventsKey = "Notifications.IncludesEvents"
    public static let includesRemindersKey = "Notifications.IncludesReminders"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public var isEnabled: Bool {
        get { defaults.bool(forKey: Self.isEnabledKey) }
        nonmutating set { defaults.set(newValue, forKey: Self.isEnabledKey) }
    }

    public var includesEvents: Bool {
        get { defaults.object(forKey: Self.includesEventsKey) as? Bool ?? true }
        nonmutating set { defaults.set(newValue, forKey: Self.includesEventsKey) }
    }

    public var includesReminders: Bool {
        get { defaults.object(forKey: Self.includesRemindersKey) as? Bool ?? true }
        nonmutating set { defaults.set(newValue, forKey: Self.includesRemindersKey) }
    }
}
