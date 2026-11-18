import Foundation

public final class BirthdaySettings: @unchecked Sendable {
    public static let markedCalendarsKey = "Birthdays.MarkedCalendars"
    public static let alertsOnTheDayKey = "Birthdays.AlertsOnTheDay"
    public static let alertsDayBeforeKey = "Birthdays.AlertsDayBefore"
    public static let shared = BirthdaySettings()

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public var markedCalendarIdentifiers: Set<String> {
        get { Set(defaults.stringArray(forKey: Self.markedCalendarsKey) ?? []) }
        set { defaults.set(newValue.sorted(), forKey: Self.markedCalendarsKey) }
    }

    public var alertsOnTheDay: Bool {
        get { defaults.object(forKey: Self.alertsOnTheDayKey) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Self.alertsOnTheDayKey) }
    }

    public var alertsDayBefore: Bool {
        get { defaults.bool(forKey: Self.alertsDayBeforeKey) }
        set { defaults.set(newValue, forKey: Self.alertsDayBeforeKey) }
    }

    /// The alerts birthday events get when they have none of their own, retimed to the calendar's all-day alert time.
    public var defaultAlarms: [CalendarAlarm] {
        let day: TimeInterval = 24 * 60 * 60
        return (alertsOnTheDay ? [CalendarAlarm.relative(offset: 0)] : [])
            + (alertsDayBefore ? [CalendarAlarm.relative(offset: -day)] : [])
    }
}
