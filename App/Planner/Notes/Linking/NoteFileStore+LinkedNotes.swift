import Foundation

extension NoteFileStore {
    /// Leaves an existing note at `relativePath` untouched and returns it instead.
    @concurrent
    func createNoteIfMissing(atRelativePath relativePath: String, text: String) async throws -> Note {
        let url = rootURL.appending(path: relativePath)
        guard isNoteURL(url) else {
            throw NotesStorageError.invalidTitle
        }
        if NoteFileNaming.exists(url) {
            return try await read(url)
        }
        try ensureDirectoryExists(url.deletingLastPathComponent())
        return try FileCoordination.write(at: url, options: .forReplacing) { coordinatedURL in
            try Data(text.utf8).write(to: coordinatedURL, options: .withoutOverwriting)
            return Note(url: url, modifiedDate: modificationDate(of: coordinatedURL), text: text)
        }
    }
}
