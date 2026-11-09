import Foundation

/// macOS only plays custom notification sounds from `~/Library/Sounds`, which the sandbox
/// can't write to until the person picks that folder, so the pick is kept as a bookmark.
public struct NotificationSoundFolder: @unchecked Sendable {
    public static let bookmarkKey = "Notifications.SoundFolderBookmark"

    public enum InstallError: Error {
        case wrongFolder
    }

    private let defaults: UserDefaults
    private let sourceBundleURL: URL
    private let expectedFolderURL: URL

    public init(
        defaults: UserDefaults = AppGroup.userDefaults,
        sourceBundleURL: URL = Bundle.main.resourceURL ?? Bundle.main.bundleURL,
        expectedFolderURL: URL = Self.userSoundsURL
    ) {
        self.defaults = defaults
        self.sourceBundleURL = sourceBundleURL
        self.expectedFolderURL = expectedFolderURL
    }

    public static var userSoundsURL: URL {
        let home = getpwuid(getuid())?.pointee.pw_dir.map { String(cString: $0) } ?? NSHomeDirectory()
        return URL(filePath: home, directoryHint: .isDirectory)
            .appending(path: "Library/Sounds", directoryHint: .isDirectory)
    }

    public func install(into folderURL: URL) throws {
        guard Self.path(of: folderURL) == Self.path(of: expectedFolderURL) else { throw InstallError.wrongFolder }
        let isAccessing = folderURL.startAccessingSecurityScopedResource()
        defer { if isAccessing { folderURL.stopAccessingSecurityScopedResource() } }
        defaults.set(try folderURL.bookmarkData(options: Self.bookmarkCreationOptions), forKey: Self.bookmarkKey)
    }

    public func refresh() -> Bool {
        guard let folderURL = resolvedFolderURL() else { return false }
        let isAccessing = folderURL.startAccessingSecurityScopedResource()
        defer { if isAccessing { folderURL.stopAccessingSecurityScopedResource() } }
        let installed = NotificationSoundLibrary(sourceBundleURL: sourceBundleURL, destinationURL: folderURL).install()
        return installed.count == NotificationSoundLibrary.bundledSounds.count
    }

    private func resolvedFolderURL() -> URL? {
        guard let bookmark = defaults.data(forKey: Self.bookmarkKey) else { return nil }
        var isStale = false
        guard let folderURL = try? URL(
            resolvingBookmarkData: bookmark,
            options: Self.bookmarkResolutionOptions,
            bookmarkDataIsStale: &isStale
        ) else { return nil }
        if isStale {
            try? install(into: folderURL)
        }
        return folderURL
    }

    private static func path(of url: URL) -> String {
        url.standardizedFileURL.resolvingSymlinksInPath().path(percentEncoded: false)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    #if os(macOS)
    private static let bookmarkCreationOptions: URL.BookmarkCreationOptions = .withSecurityScope
    private static let bookmarkResolutionOptions: URL.BookmarkResolutionOptions = .withSecurityScope
    #else
    private static let bookmarkCreationOptions: URL.BookmarkCreationOptions = []
    private static let bookmarkResolutionOptions: URL.BookmarkResolutionOptions = []
    #endif
}
