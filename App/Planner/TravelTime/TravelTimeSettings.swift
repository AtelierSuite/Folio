import Foundation

public struct TravelTimeSettings: @unchecked Sendable {
    public static let isEnabledKey = "TravelTime.Enabled"
    public static let transportKey = "TravelTime.Transport"
    public static let firstEventOriginKey = "TravelTime.FirstEventOrigin"
    public static let startingLocationKey = "TravelTime.StartingLocation"

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

    public var firstEventOrigin: TravelOrigin {
        get {
            defaults.string(forKey: Self.firstEventOriginKey).flatMap(TravelOrigin.init(rawValue:)) ?? .currentLocation
        }
        nonmutating set { defaults.set(newValue.rawValue, forKey: Self.firstEventOriginKey) }
    }

    public var startingLocation: EventLocation? {
        get {
            defaults.data(forKey: Self.startingLocationKey)
                .flatMap { try? JSONDecoder().decode(EventLocation.self, from: $0) }
        }
        nonmutating set {
            if let newValue, let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: Self.startingLocationKey)
            } else {
                defaults.removeObject(forKey: Self.startingLocationKey)
            }
        }
    }
}
