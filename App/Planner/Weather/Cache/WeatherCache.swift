import Foundation

/// Weather saved as JSON in the App Group so widgets can read it without fetching:
/// `Library/Caches/Weather/<latitude>_<longitude>/<yyyy-MM-dd>.json`, one `WeatherCacheEntry` per file,
/// plus `attribution.json`.
public struct WeatherCache: Sendable {
    public let directory: URL

    public init(directory: URL = WeatherCache.defaultDirectory) {
        self.directory = directory
    }

    public static var defaultDirectory: URL {
        AppGroup.containerURL.appending(path: "Library/Caches/Weather", directoryHint: .isDirectory)
    }

    public static func dayKey(for dayStart: Date, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: dayStart)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }

    public func fileURL(for location: WeatherLocationKey, dayKey: String) -> URL {
        directory
            .appending(path: location.pathComponent, directoryHint: .isDirectory)
            .appending(path: "\(dayKey).json", directoryHint: .notDirectory)
    }

    public func entry(for location: WeatherLocationKey, dayStart: Date, calendar: Calendar) -> WeatherCacheEntry? {
        let url = fileURL(for: location, dayKey: Self.dayKey(for: dayStart, calendar: calendar))
        guard let data = try? Data(contentsOf: url),
              let entry = try? JSONDecoder().decode(WeatherCacheEntry.self, from: data),
              entry.day.dayStart == dayStart else { return nil }
        return entry
    }

    public func store(_ entry: WeatherCacheEntry, for location: WeatherLocationKey, calendar: Calendar) {
        let url = fileURL(for: location, dayKey: Self.dayKey(for: entry.day.dayStart, calendar: calendar))
        guard let data = try? JSONEncoder().encode(entry) else { return }
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? data.write(to: url, options: .atomic)
    }

    public var attribution: WeatherAttribution? {
        guard let data = try? Data(contentsOf: attributionURL) else { return nil }
        return try? JSONDecoder().decode(WeatherAttribution.self, from: data)
    }

    public func store(_ attribution: WeatherAttribution) {
        guard let data = try? JSONEncoder().encode(attribution) else { return }
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try? data.write(to: attributionURL, options: .atomic)
    }

    private var attributionURL: URL {
        directory.appending(path: "attribution.json", directoryHint: .notDirectory)
    }
}
