import Foundation

public struct CountdownSettings: @unchecked Sendable {
    public static let countsToStartKey = "Countdown.CountsToStart"
    public static let countsToEndKey = "Countdown.CountsToEnd"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public var phases: CountdownPhases {
        get {
            CountdownPhases(
                countsToStart: defaults.object(forKey: Self.countsToStartKey) as? Bool ?? true,
                countsToEnd: defaults.object(forKey: Self.countsToEndKey) as? Bool ?? true
            )
        }
        nonmutating set {
            defaults.set(newValue.countsToStart, forKey: Self.countsToStartKey)
            defaults.set(newValue.countsToEnd, forKey: Self.countsToEndKey)
        }
    }
}
