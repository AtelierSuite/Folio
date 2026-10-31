import Foundation

extension NoteFileStore {
    /// Downloads the note first if iCloud hasn't put it on this device yet.
    @concurrent
    public func read(_ url: URL) async throws -> Note {
        try await ensureDownloaded(url)
        try preserveConflictVersions(of: url)
        let store = self
        return try await FileCoordination.readDownloading(at: url) { coordinatedURL in
            try store.loadNote(at: coordinatedURL, reportedURL: url)
        }
    }

    @concurrent
    public func ensureDownloaded(_ url: URL) async throws {
        try await FileCoordination.readDownloading(at: url) { _ in }
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
