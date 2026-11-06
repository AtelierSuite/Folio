import Foundation

public struct EventLocationSettings {
    public static let defaultLocationKey = "Events.DefaultLocation"
    public static let savedLocationsKey = "Events.SavedLocations"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public var defaultLocation: EventLocation? {
        get { decoded(EventLocation.self, forKey: Self.defaultLocationKey) }
        nonmutating set { encode(newValue, forKey: Self.defaultLocationKey) }
    }

    public var savedLocations: [SavedLocation] {
        get { decoded([SavedLocation].self, forKey: Self.savedLocationsKey) ?? [] }
        nonmutating set { encode(newValue.isEmpty ? nil : newValue, forKey: Self.savedLocationsKey) }
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
