import Foundation

public struct TimeZoneOption: Identifiable, Hashable, Sendable {
    public let identifier: String
    public let cityName: String?
    public let regionName: String
    public let abbreviation: String
    public let offset: String
    public let regionCode: String?

    public var id: String {
        identifier
    }

    public var displayName: String {
        cityName ?? regionName
    }

    public var shortLabel: String {
        cityName ?? abbreviation
    }

    /// Short enough for the narrow time zone column header.
    public var columnLabel: String {
        regionCode ?? shortLabel
    }

    public init?(identifier: String, locale: Locale = .autoupdatingCurrent, date: Date = .now) {
        guard let timeZone = TimeZone(identifier: identifier) else { return nil }
        self.identifier = identifier
        cityName = Self.cityName(of: timeZone, locale: locale)
        regionName = timeZone.localizedName(for: .generic, locale: locale) ?? identifier
        abbreviation = timeZone.abbreviation(for: date) ?? identifier
        regionCode = TimeZoneRegions.regionCode(for: identifier)
        offset = date.formatted(
            Date.FormatStyle(locale: locale, timeZone: timeZone).timeZone(.localizedGMT(.short))
        )
    }

    public func matches(_ query: String) -> Bool {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return true }
        let searchable = [cityName ?? "", regionName, abbreviation, offset, identifier.replacing("_", with: " ")]
        return searchable.contains { $0.localizedStandardContains(trimmed) }
    }

    /// Zones like `GMT` or `Etc/GMT+5` are not tied to a city.
    private static func cityName(of timeZone: TimeZone, locale: Locale) -> String? {
        let identifier = timeZone.identifier
        guard identifier.contains("/"), !identifier.hasPrefix("Etc/") else { return nil }
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.dateFormat = "VVV"
        let name = formatter.string(from: .now)
        return name.isEmpty ? nil : name
    }
}
