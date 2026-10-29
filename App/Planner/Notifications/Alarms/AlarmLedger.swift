import Foundation

public struct AlarmLedger: @unchecked Sendable {
    public static let key = "Notifications.ScheduledAlarms"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public var identifiers: Set<UUID> {
        get { Set((defaults.stringArray(forKey: Self.key) ?? []).compactMap(UUID.init(uuidString:))) }
        nonmutating set { defaults.set(newValue.map(\.uuidString).sorted(), forKey: Self.key) }
    }
}
