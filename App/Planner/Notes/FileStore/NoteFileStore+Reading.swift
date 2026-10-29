import Foundation

extension NoteFileStore {
    @concurrent
    public func read(_ url: URL) async throws -> Note {
        try await downloadIfNeeded(url)
        try preserveConflictVersions(of: url)
        return try FileCoordination.read(at: url) { coordinatedURL in
            try loadNote(at: coordinatedURL, reportedURL: url)
        }
    }

    @concurrent
    public func downloadIfNeeded(_ url: URL, timeout: Duration = .seconds(60)) async throws {
        guard isEvicted(url) else {
            return
        }
        try FileManager.default.startDownloadingUbiquitousItem(at: url)
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: timeout)
        while isEvicted(url) {
            guard clock.now < deadline else {
                throw NotesStorageError.downloadTimedOut
            }
            try await Task.sleep(for: .milliseconds(250))
        }
    }

    func isEvicted(_ url: URL) -> Bool {
        let fileManager = FileManager.default
        guard fileManager.isUbiquitousItem(at: url) else {
            return false
        }
        var freshURL = url
        freshURL.removeAllCachedResourceValues()
        let status = try? freshURL.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
            .ubiquitousItemDownloadingStatus
        return status != .current
    }

    func loadNote(at url: URL, reportedURL: URL) throws -> Note {
        let data = try Data(contentsOf: url)
        guard let text = String(data: data, encoding: .utf8) else {
            throw NotesStorageError.unreadableText
        }
        return Note(url: reportedURL, modifiedDate: modificationDate(of: url), text: text)
    }

    func modificationDate(of url: URL) -> Date {
        var freshURL = url
        freshURL.removeAllCachedResourceValues()
        return (try? freshURL.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .now
    }
}
