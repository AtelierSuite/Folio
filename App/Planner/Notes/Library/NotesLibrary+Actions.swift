import Foundation

extension NotesLibrary {
    public func read(_ url: URL) async throws -> Note {
        try await requireStore().read(url)
    }

    public func save(_ text: String, over note: Note) async throws -> NoteSaveResult {
        let result = try await requireStore().save(text, over: note)
        await refresh()
        return result
    }

    public func createNote(titled title: String, text: String = "") async throws -> Note {
        let note = try await requireStore().createNote(titled: title, text: text)
        await refresh()
        return note
    }

    public func rename(_ url: URL, to title: String) async throws -> URL {
        let newURL = try await requireStore().rename(url, to: title)
        moveLinks(from: url, to: newURL)
        await refresh()
        return newURL
    }

    @discardableResult
    public func moveToTrash(_ url: URL) async throws -> URL {
        let trashedURL = try await requireStore().moveToTrash(url)
        moveLinks(from: url, to: trashedURL)
        await refresh()
        return trashedURL
    }

    @discardableResult
    public func restore(_ trashedURL: URL) async throws -> URL {
        let url = try await requireStore().restore(trashedURL)
        moveLinks(from: trashedURL, to: url)
        await refresh()
        return url
    }

    public func deletePermanently(_ trashedURL: URL) async throws {
        try await requireStore().deletePermanently(trashedURL)
        unlinkTrashed(at: trashedURL)
        await refresh()
    }

    public func emptyTrash() async throws {
        try await requireStore().emptyTrash()
        unlinkTrashed(at: nil)
        await refresh()
    }

    public func addAsset(_ data: Data, named fileName: String, for noteURL: URL) async throws -> String {
        try await requireStore().addAsset(data, named: fileName, for: noteURL)
    }

    func requireStore() throws -> NoteFileStore {
        guard let store else {
            throw mode == .iCloudDrive ? NotesStorageError.iCloudUnavailable : NotesStorageError.folderNotChosen
        }
        return store
    }
}
