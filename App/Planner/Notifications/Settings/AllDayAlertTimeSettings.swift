import Foundation

public final class AllDayAlertTimeSettings: @unchecked Sendable {
    public static let calendarTimesKey = "Notifications.AllDayAlertTimes"
    public static let defaultMinutesAfterMidnight = 8 * 60
    public static let shared = AllDayAlertTimeSettings()

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public func minutesAfterMidnight(forCalendar calendarIdentifier: String) -> Int {
        calendarTimes[calendarIdentifier] ?? Self.defaultMinutesAfterMidnight
    }

    public func setMinutesAfterMidnight(_ minutes: Int, forCalendar calendarIdentifier: String) {
        var times = calendarTimes
        let clamped = min(max(minutes, 0), 24 * 60 - 1)
        times[calendarIdentifier] = clamped == Self.defaultMinutesAfterMidnight ? nil : clamped
        defaults.set(times, forKey: Self.calendarTimesKey)
    }

    private var calendarTimes: [String: Int] {
        defaults.dictionary(forKey: Self.calendarTimesKey) as? [String: Int] ?? [:]
    }
}
