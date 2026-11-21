import Foundation

extension WeatherCache {
    public static let unusedLocationLifetime: TimeInterval = 30 * 86400

    /// Writing a day replaces its file, which touches the folder, so a folder untouched for a month
    /// belongs to somewhere the user no longer is.
    public func removeLocations(unusedSince cutoff: Date) {
        let fileManager = FileManager.default
        guard let folders = try? fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isDirectoryKey, .contentModificationDateKey]
        ) else { return }
        for folder in folders {
            guard let values = try? folder.resourceValues(forKeys: [.isDirectoryKey, .contentModificationDateKey]),
                  values.isDirectory == true,
                  let modified = values.contentModificationDate,
                  modified < cutoff else { continue }
            try? fileManager.removeItem(at: folder)
        }
    }
}
