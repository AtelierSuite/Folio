import Foundation

public struct WakeUpAlarmSettings: @unchecked Sendable {
    public static let isEnabledKey = "WakeUpAlarm.Enabled"
    public static let leadMinutesKey = "WakeUpAlarm.LeadMinutes"
    public static let earliestMinutesKey = "WakeUpAlarm.EarliestMinutes"
    public static let latestEventMinutesKey = "WakeUpAlarm.LatestEventMinutes"

    public static let defaultLeadMinutes = 90
    public static let defaultEarliestMinutes = 6 * 60
    public static let defaultLatestEventMinutes = 12 * 60

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public var isEnabled: Bool {
        get { defaults.bool(forKey: Self.isEnabledKey) }
        nonmutating set { defaults.set(newValue, forKey: Self.isEnabledKey) }
    }

    public var leadMinutes: Int {
        get { minutes(forKey: Self.leadMinutesKey) ?? Self.defaultLeadMinutes }
        nonmutating set { defaults.set(newValue, forKey: Self.leadMinutesKey) }
    }

    /// Minutes after midnight before which the alarm never rings.
    public var earliestMinutes: Int {
        get { minutes(forKey: Self.earliestMinutesKey) ?? Self.defaultEarliestMinutes }
        nonmutating set { defaults.set(newValue, forKey: Self.earliestMinutesKey) }
    }

    /// Minutes after midnight from which events no longer count as a morning's first event.
    public var latestEventMinutes: Int {
        get { minutes(forKey: Self.latestEventMinutesKey) ?? Self.defaultLatestEventMinutes }
        nonmutating set { defaults.set(newValue, forKey: Self.latestEventMinutesKey) }
    }

    private func minutes(forKey key: String) -> Int? {
        defaults.object(forKey: key) as? Int
    }
}
