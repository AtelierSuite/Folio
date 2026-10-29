import Foundation

public enum AppGroup {
    public static let identifier = "group.com.tsubuzaki.Folio"

    public static var containerURL: URL {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
            ?? URL.applicationSupportDirectory
    }

    /// One shared instance so `@AppStorage` views using this store see each other's changes.
    /// `UserDefaults` is thread-safe.
    nonisolated(unsafe) public static let userDefaults = UserDefaults(suiteName: identifier) ?? .standard
}
