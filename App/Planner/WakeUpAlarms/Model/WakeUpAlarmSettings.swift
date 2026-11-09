import Foundation

public struct WakeUpAlarmSettings: @unchecked Sendable {
    public static let isEnabledKey = "WakeUpAlarm.Enabled"
    public static let leadMinutesKey = "WakeUpAlarm.LeadMinutes"
    public static let earliestMinutesKey = "WakeUpAlarm.EarliestMinutes"
    public static let latestEventMinutesKey = "WakeUpAlarm.LatestEventMinutes"
    public static let skipsHolidaysKey = "WakeUpAlarm.SkipsHolidays"
    public static let excludedCalendarIdentifiersKey = "WakeUpAlarm.ExcludedCalendars"
    public static let upcomingFireDatesKey = "WakeUpAlarm.UpcomingFireDates"

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

    /// Only takes effect while holidays are highlighted in the calendar.
    public var skipsHolidays: Bool {
        get { defaults.bool(forKey: Self.skipsHolidaysKey) }
        nonmutating set { defaults.set(newValue, forKey: Self.skipsHolidaysKey) }
    }

    public var excludedCalendarIdentifiers: Set<String> {
        get { Set(defaults.stringArray(forKey: Self.excludedCalendarIdentifiersKey) ?? []) }
        nonmutating set { defaults.set(newValue.sorted(), forKey: Self.excludedCalendarIdentifiersKey) }
    }

    /// When the scheduled alarms ring, kept here because widgets can't reach the app's planner.
    public var upcomingFireDates: [Date] {
        get { defaults.array(forKey: Self.upcomingFireDatesKey) as? [Date] ?? [] }
        nonmutating set { defaults.set(newValue, forKey: Self.upcomingFireDatesKey) }
    }

    public var highlightedHolidaySource: HolidaySource? {
        guard defaults.bool(forKey: DayHighlightSettings.highlightsHolidaysKey),
              let regionCode = DayHighlightSettings.resolvedRegionCode(
                stored: defaults.string(forKey: DayHighlightSettings.holidayRegionKey) ?? ""
              ) else { return nil }
        return HolidaySource(regionCode: regionCode)
    }

    private func minutes(forKey key: String) -> Int? {
        defaults.object(forKey: key) as? Int
    }
}
