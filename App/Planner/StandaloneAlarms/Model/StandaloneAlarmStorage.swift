import Foundation

public struct StandaloneAlarmStorage: @unchecked Sendable {
    public static let key = "StandaloneAlarms.Alarms"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public var alarms: [StandaloneAlarm] {
        get {
            guard let data = defaults.data(forKey: Self.key) else { return [] }
            return (try? JSONDecoder().decode([StandaloneAlarm].self, from: data)) ?? []
        }
        nonmutating set {
            defaults.set(try? JSONEncoder().encode(newValue), forKey: Self.key)
        }
    }
}
