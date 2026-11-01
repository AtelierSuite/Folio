import Foundation

/// Holidays saved as JSON in the App Group: `Library/Caches/Holidays/<source>.json`.
public struct HolidayCache: Sendable {
    public let directory: URL

    public init(directory: URL = HolidayCache.defaultDirectory) {
        self.directory = directory
    }

    public static var defaultDirectory: URL {
        AppGroup.containerURL.appending(path: "Library/Caches/Holidays", directoryHint: .isDirectory)
    }

    func entry(for source: HolidaySource) -> HolidayCacheEntry? {
        guard let data = try? Data(contentsOf: fileURL(for: source)) else { return nil }
        return try? JSONDecoder().decode(HolidayCacheEntry.self, from: data)
    }

    func store(_ entry: HolidayCacheEntry, for source: HolidaySource) {
        guard let data = try? JSONEncoder().encode(entry) else { return }
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try? data.write(to: fileURL(for: source), options: .atomic)
    }

    private func fileURL(for source: HolidaySource) -> URL {
        directory.appending(path: "\(source.cacheKey).json", directoryHint: .notDirectory)
    }
}
