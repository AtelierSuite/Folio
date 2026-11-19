import Foundation

public struct AlarmSnoozeSettings: @unchecked Sendable {
    public static let minutesKey = "Alarms.Snooze.Minutes"
    public static let standardMinutes = 9
    public static let choices = Array(1...30)

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public var minutes: Int {
        get { Self.clamped(defaults.object(forKey: Self.minutesKey) as? Int ?? Self.standardMinutes) }
        nonmutating set { defaults.set(Self.clamped(newValue), forKey: Self.minutesKey) }
    }

    public var duration: TimeInterval {
        TimeInterval(minutes * 60)
    }

    public static func clamped(_ minutes: Int) -> Int {
        min(max(minutes, choices.first ?? 1), choices.last ?? 30)
    }
}
