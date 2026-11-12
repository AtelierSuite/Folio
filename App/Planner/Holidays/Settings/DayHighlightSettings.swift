import Foundation

public enum DayHighlightSettings {
    public static let highlightsWeekendsKey = "Calendar.HighlightsWeekends"
    public static let highlightsHolidaysKey = "Calendar.HighlightsHolidays"
    /// Empty follows the device region.
    public static let holidayRegionKey = "Calendar.HolidayRegion"
    /// Bumped after a manual refresh so calendar views reload the downloaded holidays.
    public static let holidaysRefreshedAtKey = "Calendar.HolidaysRefreshedAt"

    public static func resolvedRegionCode(stored: String, locale: Locale = .current) -> String? {
        let code = stored.isEmpty ? locale.region?.identifier : stored
        return code.flatMap { HolidaySource.supportedRegionCodes.contains($0) ? $0 : nil }
    }

    /// The holidays shown in the calendar, or `nil` while holidays aren't highlighted.
    public static func highlightedHolidaySource(in defaults: UserDefaults = AppGroup.userDefaults) -> HolidaySource? {
        guard defaults.bool(forKey: highlightsHolidaysKey),
              let regionCode = resolvedRegionCode(stored: defaults.string(forKey: holidayRegionKey) ?? "") else {
            return nil
        }
        return HolidaySource(regionCode: regionCode)
    }

    public static func sortedRegionCodes(in locale: Locale) -> [String] {
        HolidaySource.supportedRegionCodes.sorted { first, second in
            let firstName = regionName(for: first, in: locale)
            return firstName.localizedStandardCompare(regionName(for: second, in: locale)) == .orderedAscending
        }
    }

    public static func regionName(for regionCode: String, in locale: Locale) -> String {
        locale.localizedString(forRegionCode: regionCode) ?? regionCode
    }
}
