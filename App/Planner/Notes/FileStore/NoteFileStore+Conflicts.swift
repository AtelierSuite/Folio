import Foundation

extension NoteFileStore {
    @concurrent
    public func resolveConflicts(of url: URL) async throws -> [URL] {
        try await preserveConflictVersions(of: url)
    }

    @discardableResult
    func preserveConflictVersions(of url: URL) async throws -> [URL] {
        guard NSFileVersion.unresolvedConflictVersionsOfItem(at: url)?.isEmpty == false else {
            return []
        }
        let store = self
        return try await FileCoordination.write(at: url) { coordinatedURL in
            guard let versions = NSFileVersion.unresolvedConflictVersionsOfItem(at: coordinatedURL),
                  !versions.isEmpty else {
                return []
            }
            let currentText = try? String(contentsOf: coordinatedURL, encoding: .utf8)
            var copies: [URL] = []
            var leftUnresolved = false
            for version in versions {
                let action = NoteConflictVersionAction(
                    versionText: try? String(contentsOf: version.url, encoding: .utf8),
                    currentText: currentText
                )
                if case .saveConflictedCopy(let versionText) = action {
                    let copyURL = try store.writeConflictedCopy(
                        versionText, besides: coordinatedURL, date: version.modificationDate ?? .now
                    )
                    copies.append(copyURL)
                }
                if action.resolvesVersion {
                    version.isResolved = true
                } else {
                    leftUnresolved = true
                }
            }
            if !leftUnresolved {
                try NSFileVersion.removeOtherVersionsOfItem(at: coordinatedURL)
            }
            return copies
        }
    }

    func writeConflictedCopy(_ text: String, besides url: URL, date: Date) throws -> URL {
        let copyURL = conflictedCopyURL(besides: url, date: date)
        try FileCoordination.write(at: copyURL, options: .forReplacing) { coordinatedURL in
            try Data(text.utf8).write(to: coordinatedURL, options: .atomic)
        }
        return copyURL
    }

    func conflictedCopyURL(besides url: URL, date: Date) -> URL {
        let name = NoteFileNaming.conflictedCopyName(title: url.noteTitle, date: date)
        return NoteFileNaming.uniqueURL(for: url.deletingLastPathComponent().appending(path: name))
    }
}
