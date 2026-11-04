import Foundation

public struct AlternateCalendarSettings: @unchecked Sendable {
    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public var selected: AlternateCalendar? {
        defaults.string(forKey: AlternateCalendar.storageKey).flatMap(AlternateCalendar.init(rawValue:))
    }

    public func formatter(timeZone: TimeZone, locale: Locale) -> AlternateCalendarFormatter? {
        selected.map { AlternateCalendarFormatter(alternateCalendar: $0, timeZone: timeZone, locale: locale) }
    }
}
