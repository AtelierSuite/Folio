import Foundation

public struct EventTapSettings: @unchecked Sendable {
    public static let behaviorKey = "Calendar.EventTapBehavior"
    public static let defaultBehavior = EventTapBehavior.opensDetails

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public var behavior: EventTapBehavior {
        get {
            defaults.string(forKey: Self.behaviorKey).flatMap(EventTapBehavior.init(rawValue:)) ?? Self.defaultBehavior
        }
        nonmutating set { defaults.set(newValue.rawValue, forKey: Self.behaviorKey) }
    }
}
