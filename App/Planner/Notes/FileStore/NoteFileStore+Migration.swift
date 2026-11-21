import Foundation

extension NoteFileStore {
    /// Copies notes, assets and the trash into `destination`. Files that already exist there with
    /// different contents are kept under a new name, so nothing is overwritten.
    @concurrent
    public func migrate(to destination: NoteFileStore, removingSource: Bool) async throws -> NotesMigrationSummary {
        var summary = NotesMigrationSummary()
        guard destination.rootURL != rootURL else {
            return summary
        }
        try destination.ensureDirectoryExists(destination.rootURL)
        for relativePath in try migratableRelativePaths() {
            let sourceURL = rootURL.appending(path: relativePath)
            try await ensureDownloaded(sourceURL)
            let target = destination.rootURL.appending(path: relativePath)
            if NoteFileNaming.exists(target) {
                if try await destination.contentsMatch(of: target, and: sourceURL) {
                    summary.skippedDuplicateCount += 1
                    try await removeIfNeeded(sourceURL, removingSource: removingSource)
                    continue
                }
                summary.renamedFileCount += 1
            }
            try await FileCoordination.copy(from: sourceURL, to: NoteFileNaming.uniqueURL(for: target))
            summary.copiedFileCount += 1
            try await removeIfNeeded(sourceURL, removingSource: removingSource)
        }
        if removingSource {
            await removeEmptyFolders()
        }
        return summary
    }

    func removeEmptyFolders() async {
        let folders = (FileManager.default.enumerator(at: rootURL, includingPropertiesForKeys: [.isDirectoryKey])?
            .compactMap { $0 as? URL }
            .filter { (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true } ?? [])
            .sorted { $0.pathComponents.count > $1.pathComponents.count }
        for folder in folders {
            let contents = try? FileManager.default.contentsOfDirectory(atPath: folder.path(percentEncoded: false))
            if contents?.isEmpty == true {
                try? await FileCoordination.delete(at: folder)
            }
        }
    }

    func migratableRelativePaths() throws -> [String] {
        guard let enumerator = FileManager.default.enumerator(
            at: rootURL, includingPropertiesForKeys: [.isDirectoryKey]
        ) else {
            return []
        }
        var paths: [String] = []
        for case let url as URL in enumerator {
            let name = url.lastPathComponent
            let isDirectory = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
            if isDirectory {
                if name.hasPrefix("."), name != Self.trashFolderName {
                    enumerator.skipDescendants()
                }
                continue
            }
            let realURL = NoteFileNaming.realName(forPlaceholderName: name)
                .map { url.deletingLastPathComponent().appending(path: $0) }
            if realURL == nil, name.hasPrefix(".") {
                continue
            }
            if let path = relativePath(of: realURL ?? url) {
                paths.append(path)
            }
        }
        return paths.sorted()
    }

    func contentsMatch(of url: URL, and otherURL: URL) async throws -> Bool {
        guard FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) else {
            return false
        }
        let data = try await FileCoordination.read(at: url) { try Data(contentsOf: $0) }
        let otherData = try await FileCoordination.read(at: otherURL) { try Data(contentsOf: $0) }
        return data == otherData
    }

    private func removeIfNeeded(_ url: URL, removingSource: Bool) async throws {
        if removingSource {
            try await FileCoordination.delete(at: url)
        }
    }
}
