import Foundation

public struct SecondaryTimeZoneSettings: @unchecked Sendable {
    public static let isEnabledKey = "TimeZones.Secondary.Enabled"
    public static let identifierKey = "TimeZones.Secondary.Identifier"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public var isEnabled: Bool {
        get { defaults.bool(forKey: Self.isEnabledKey) }
        nonmutating set { defaults.set(newValue, forKey: Self.isEnabledKey) }
    }

    public var identifier: String {
        get { defaults.string(forKey: Self.identifierKey) ?? "" }
        nonmutating set { defaults.set(newValue, forKey: Self.identifierKey) }
    }

    public var shownTimeZone: TimeZone? {
        Self.shownTimeZone(isEnabled: isEnabled, identifier: identifier)
    }

    public static func shownTimeZone(isEnabled: Bool, identifier: String) -> TimeZone? {
        guard isEnabled, !identifier.isEmpty else { return nil }
        return TimeZone(identifier: identifier)
    }
}
