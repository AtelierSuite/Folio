import Foundation

/// Weather preferences in the App Group defaults, so widgets resolve the same location as the app.
public struct WeatherSettings: @unchecked Sendable {
    public static let isEnabledKey = "Weather.Enabled"
    public static let locationModeKey = "Weather.LocationMode"
    public static let chosenPlaceKey = "Weather.ChosenPlace"
    public static let lastLocationFixKey = "Weather.LastLocationFix"

    private let defaults: UserDefaults
    private let isEnabledByDefault: Bool

    public init(defaults: UserDefaults = AppGroup.userDefaults, isEnabledByDefault: Bool = false) {
        self.defaults = defaults
        self.isEnabledByDefault = isEnabledByDefault
    }

    public var isEnabled: Bool {
        get { defaults.object(forKey: Self.isEnabledKey) as? Bool ?? isEnabledByDefault }
        nonmutating set { defaults.set(newValue, forKey: Self.isEnabledKey) }
    }

    public var locationMode: WeatherLocationMode {
        get { defaults.string(forKey: Self.locationModeKey).flatMap(WeatherLocationMode.init) ?? .current }
        nonmutating set { defaults.set(newValue.rawValue, forKey: Self.locationModeKey) }
    }

    public var chosenPlace: WeatherPlace? {
        get { decoded(WeatherPlace.self, forKey: Self.chosenPlaceKey) }
        nonmutating set { encode(newValue, forKey: Self.chosenPlaceKey) }
    }

    /// The last current location the app saw, for widgets that can't ask for one.
    public var lastLocationFix: WeatherLocationFix? {
        get { decoded(WeatherLocationFix.self, forKey: Self.lastLocationFixKey) }
        nonmutating set { encode(newValue, forKey: Self.lastLocationFixKey) }
    }

    private func decoded<Value: Decodable>(_ type: Value.Type, forKey key: String) -> Value? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private func encode(_ value: (some Encodable)?, forKey key: String) {
        if let value, let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
    }
}
