import Foundation

extension NoteFileStore {
    @concurrent
    public func resolveConflicts(of url: URL) async throws -> [URL] {
        try preserveConflictVersions(of: url)
    }

    @discardableResult
    func preserveConflictVersions(of url: URL) throws -> [URL] {
        guard let versions = NSFileVersion.unresolvedConflictVersionsOfItem(at: url), !versions.isEmpty else {
            return []
        }
        return try FileCoordination.write(at: url) { coordinatedURL in
            let currentText = try? String(contentsOf: coordinatedURL, encoding: .utf8)
            var copies: [URL] = []
            for version in versions {
                let versionText = try? String(contentsOf: version.url, encoding: .utf8)
                if let versionText, versionText != currentText {
                    let copyURL = try writeConflictedCopy(
                        versionText, besides: coordinatedURL, date: version.modificationDate ?? .now
                    )
                    copies.append(copyURL)
                }
                version.isResolved = true
            }
            try NSFileVersion.removeOtherVersionsOfItem(at: coordinatedURL)
            return copies
        }
    }

    func writeConflictedCopy(_ text: String, besides url: URL, date: Date) throws -> URL {
        let name = NoteFileNaming.conflictedCopyName(title: url.noteTitle, date: date)
        let copyURL = NoteFileNaming.uniqueURL(for: url.deletingLastPathComponent().appending(path: name))
        try FileCoordination.write(at: copyURL, options: .forReplacing) { coordinatedURL in
            try Data(text.utf8).write(to: coordinatedURL, options: .atomic)
        }
        return copyURL
    }
}
