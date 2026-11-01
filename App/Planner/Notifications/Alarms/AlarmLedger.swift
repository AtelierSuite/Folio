import Foundation

/// The alarms one feature scheduled, so it only cancels its own and leaves the others' alone.
public struct AlarmLedger: @unchecked Sendable {
    public static let key = "Notifications.ScheduledAlarms"

    private let defaults: UserDefaults
    private let key: String

    public init(key: String = Self.key, defaults: UserDefaults = AppGroup.userDefaults) {
        self.key = key
        self.defaults = defaults
    }

    public var identifiers: Set<UUID> {
        get { Set((defaults.stringArray(forKey: key) ?? []).compactMap(UUID.init(uuidString:))) }
        nonmutating set { defaults.set(newValue.map(\.uuidString).sorted(), forKey: key) }
    }
}
