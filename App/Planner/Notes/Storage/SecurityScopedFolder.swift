import Foundation

public final class SecurityScopedFolder: Sendable {
    public let url: URL
    private let isAccessing: Bool

    public init(url: URL) {
        self.url = url
        isAccessing = url.startAccessingSecurityScopedResource()
    }

    deinit {
        if isAccessing {
            url.stopAccessingSecurityScopedResource()
        }
    }

    public var displayName: String {
        (try? url.resourceValues(forKeys: [.localizedNameKey]).localizedName)
            ?? FileManager.default.displayName(atPath: url.path(percentEncoded: false))
    }

    public func bookmarkData() throws -> Data {
        try url.bookmarkData(options: Self.creationOptions, includingResourceValuesForKeys: nil, relativeTo: nil)
    }

    /// Resolves a saved bookmark and returns fresh bookmark data when the saved one is stale.
    public static func resolve(bookmark: Data) throws -> (folder: SecurityScopedFolder, refreshedBookmark: Data?) {
        var isStale = false
        let url = try URL(
            resolvingBookmarkData: bookmark, options: resolutionOptions, relativeTo: nil, bookmarkDataIsStale: &isStale
        )
        let folder = SecurityScopedFolder(url: url)
        return (folder, isStale ? try? folder.bookmarkData() : nil)
    }

    #if os(macOS)
    private static let creationOptions: URL.BookmarkCreationOptions = .withSecurityScope
    private static let resolutionOptions: URL.BookmarkResolutionOptions = .withSecurityScope
    #else
    private static let creationOptions: URL.BookmarkCreationOptions = []
    private static let resolutionOptions: URL.BookmarkResolutionOptions = []
    #endif
}
