import Foundation

public struct NoteFile: Identifiable, Hashable, Sendable {
    public let url: URL
    public let relativePath: String
    public let modifiedDate: Date
    public let isDownloaded: Bool
    public let hasUnresolvedConflicts: Bool

    public init(
        url: URL,
        relativePath: String,
        modifiedDate: Date,
        isDownloaded: Bool = true,
        hasUnresolvedConflicts: Bool = false
    ) {
        self.url = url
        self.relativePath = relativePath
        self.modifiedDate = modifiedDate
        self.isDownloaded = isDownloaded
        self.hasUnresolvedConflicts = hasUnresolvedConflicts
    }

    public var id: URL { url }

    public var title: String { url.noteTitle }

    public var folderPath: String {
        let components = relativePath.split(separator: "/").dropLast()
        return components.joined(separator: "/")
    }
}
