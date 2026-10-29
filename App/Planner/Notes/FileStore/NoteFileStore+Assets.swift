import Foundation

extension NoteFileStore {
    /// Returns the Markdown link path to the asset, relative to the note's folder.
    @concurrent
    public func addAsset(_ data: Data, named fileName: String, for noteURL: URL) async throws -> String {
        try ensureDirectoryExists(assetsURL)
        let safeName = NoteFileNaming.sanitizedTitle(fileName)
        let assetURL = NoteFileNaming.uniqueURL(for: assetsURL.appending(path: safeName.isEmpty ? "asset" : safeName))
        try FileCoordination.write(at: assetURL, options: .forReplacing) { coordinatedURL in
            try data.write(to: coordinatedURL, options: .withoutOverwriting)
        }
        return assetLinkPath(for: assetURL.lastPathComponent, from: noteURL)
    }

    public func assetLinkPath(for assetName: String, from noteURL: URL) -> String {
        let depth = relativePath(of: noteURL).map { $0.split(separator: "/").count - 1 } ?? 0
        let parents = String(repeating: "../", count: max(depth, 0))
        return "\(parents)\(Self.assetsFolderName)/\(assetName)"
    }

    public func resolveLink(_ linkPath: String, from noteURL: URL) -> URL {
        let decodedPath = linkPath.removingPercentEncoding ?? linkPath
        return noteURL.deletingLastPathComponent().appending(path: decodedPath).standardizedFileURL
    }
}
