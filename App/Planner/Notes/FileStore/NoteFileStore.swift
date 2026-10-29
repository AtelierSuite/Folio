import Foundation

public struct NoteFileStore: Sendable, Hashable {
    public static let trashFolderName = ".trash"
    public static let assetsFolderName = "assets"

    public let rootURL: URL

    public init(rootURL: URL) {
        self.rootURL = rootURL.standardizedFileURL
    }

    public var trashURL: URL {
        rootURL.appending(path: Self.trashFolderName, directoryHint: .isDirectory)
    }

    public var assetsURL: URL {
        rootURL.appending(path: Self.assetsFolderName, directoryHint: .isDirectory)
    }

    @concurrent
    public func notes() async throws -> [NoteFile] {
        try FileCoordination.read(at: rootURL) { coordinatedRootURL in
            try listNoteFiles(in: coordinatedRootURL, relativeTo: rootURL)
        }
    }

    public func relativePath(of url: URL) -> String? {
        relativePath(of: url, under: rootURL)
    }

    public func isNoteURL(_ url: URL) -> Bool {
        guard NoteFileNaming.noteExtensions.contains(url.pathExtension.lowercased()),
              let relativePath = relativePath(of: url) else {
            return false
        }
        let folders = relativePath.split(separator: "/").dropLast()
        return !folders.contains { $0.hasPrefix(".") || $0 == Self.assetsFolderName }
            && !url.lastPathComponent.hasPrefix(".")
    }

    func relativePath(of url: URL, under baseURL: URL) -> String? {
        let basePath = Self.canonicalPath(of: baseURL)
        let path = Self.canonicalPath(of: url)
        guard path.hasPrefix(basePath + "/") else {
            return nil
        }
        return String(path.dropFirst(basePath.count + 1))
    }

    func ensureDirectoryExists(_ url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    private static func canonicalPath(of url: URL) -> String {
        var path = url.standardizedFileURL.resolvingSymlinksInPath().path(percentEncoded: false)
        if path.hasPrefix("/private/") {
            path.removeFirst("/private".count)
        }
        while path.count > 1, path.hasSuffix("/") {
            path.removeLast()
        }
        return path
    }
}
