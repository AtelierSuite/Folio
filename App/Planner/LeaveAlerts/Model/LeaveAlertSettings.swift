import Foundation

public struct LeaveAlertSettings: @unchecked Sendable {
    public static let isEnabledKey = "LeaveAlerts.Enabled"
    public static let transportKey = "LeaveAlerts.Transport"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public var isEnabled: Bool {
        get { defaults.bool(forKey: Self.isEnabledKey) }
        nonmutating set { defaults.set(newValue, forKey: Self.isEnabledKey) }
    }

    public var transport: TravelTransport {
        get { defaults.string(forKey: Self.transportKey).flatMap(TravelTransport.init(rawValue:)) ?? .driving }
        nonmutating set { defaults.set(newValue.rawValue, forKey: Self.transportKey) }
    }
}
