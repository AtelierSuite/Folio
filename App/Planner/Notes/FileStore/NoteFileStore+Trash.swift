import Foundation

extension NoteFileStore {
    @concurrent
    public func trashedNotes() async throws -> [NoteFile] {
        try FileCoordination.read(at: trashURL) { coordinatedTrashURL in
            try listNoteFiles(in: coordinatedTrashURL, relativeTo: trashURL, includingHidden: true)
        }
    }

    @concurrent
    @discardableResult
    public func moveToTrash(_ url: URL) async throws -> URL {
        guard let relativePath = relativePath(of: url) else {
            throw CocoaError(.fileNoSuchFile)
        }
        let destination = NoteFileNaming.uniqueURL(for: trashURL.appending(path: relativePath))
        try FileCoordination.move(from: url, to: destination)
        return destination
    }

    @concurrent
    @discardableResult
    public func restore(_ trashedURL: URL) async throws -> URL {
        guard let relativePath = relativePath(of: trashedURL, under: trashURL) else {
            throw NotesStorageError.notInTrash
        }
        let destination = NoteFileNaming.uniqueURL(for: rootURL.appending(path: relativePath))
        try FileCoordination.move(from: trashedURL, to: destination)
        return destination
    }

    @concurrent
    public func deletePermanently(_ trashedURL: URL) async throws {
        guard relativePath(of: trashedURL, under: trashURL) != nil else {
            throw NotesStorageError.notInTrash
        }
        let existingURL = FileManager.default.fileExists(atPath: trashedURL.path(percentEncoded: false))
            ? trashedURL : NoteFileNaming.placeholderURL(for: trashedURL)
        try FileCoordination.delete(at: existingURL)
    }

    @concurrent
    public func emptyTrash() async throws {
        guard FileManager.default.fileExists(atPath: trashURL.path(percentEncoded: false)) else {
            return
        }
        try FileCoordination.delete(at: trashURL)
    }
}
