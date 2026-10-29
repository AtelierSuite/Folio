import Foundation

public struct ArrivalAlertSettings: @unchecked Sendable {
    public static let isEnabledKey = "ArrivalAlerts.Enabled"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public var isEnabled: Bool {
        get { defaults.bool(forKey: Self.isEnabledKey) }
        nonmutating set { defaults.set(newValue, forKey: Self.isEnabledKey) }
    }
}
