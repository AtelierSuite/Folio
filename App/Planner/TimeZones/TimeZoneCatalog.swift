import Foundation

public enum TimeZoneCatalog {
    public static func options(locale: Locale = .autoupdatingCurrent, date: Date = .now) -> [TimeZoneOption] {
        TimeZone.knownTimeZoneIdentifiers
            .filter { !$0.hasPrefix("Etc/") }
            .compactMap { TimeZoneOption(identifier: $0, locale: locale, date: date) }
            .sorted { $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending }
    }

    public static func filter(_ options: [TimeZoneOption], by query: String) -> [TimeZoneOption] {
        options.filter { $0.matches(query) }
    }
}
