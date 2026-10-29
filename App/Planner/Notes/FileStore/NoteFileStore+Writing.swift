import Foundation

extension NoteFileStore {
    @concurrent
    public func createNote(titled title: String, text: String = "") async throws -> Note {
        let name = NoteFileNaming.sanitizedTitle(title)
        guard !name.isEmpty else {
            throw NotesStorageError.invalidTitle
        }
        try ensureDirectoryExists(rootURL)
        let url = NoteFileNaming.uniqueURL(for: rootURL.appending(path: "\(name).\(NoteFileNaming.noteExtension)"))
        return try FileCoordination.write(at: url, options: .forReplacing) { coordinatedURL in
            try Data(text.utf8).write(to: coordinatedURL, options: .withoutOverwriting)
            return Note(url: url, modifiedDate: modificationDate(of: coordinatedURL), text: text)
        }
    }

    /// `note` is the version the editor started from. If the file changed on disk since then,
    /// the edited text is written to a conflicted copy instead of overwriting the other change.
    @concurrent
    public func save(_ text: String, over note: Note) async throws -> NoteSaveResult {
        try preserveConflictVersions(of: note.url)
        let current = try FileCoordination.write(at: note.url, options: .forMerging) { coordinatedURL -> Note? in
            if let diskNote = try? loadNote(at: coordinatedURL, reportedURL: note.url),
               diskNote.text != note.text, diskNote.text != text {
                return diskNote
            }
            try Data(text.utf8).write(to: coordinatedURL, options: .atomic)
            return nil
        }
        if let current {
            let copyURL = try writeConflictedCopy(text, besides: note.url, date: .now)
            return .conflict(current: current, conflictedCopyURL: copyURL)
        }
        return .saved(Note(url: note.url, modifiedDate: modificationDate(of: note.url), text: text))
    }

    @concurrent
    public func rename(_ url: URL, to title: String) async throws -> URL {
        let name = NoteFileNaming.sanitizedTitle(title)
        guard !name.isEmpty else {
            throw NotesStorageError.invalidTitle
        }
        let pathExtension = url.pathExtension.isEmpty ? NoteFileNaming.noteExtension : url.pathExtension
        let target = url.deletingLastPathComponent().appending(path: "\(name).\(pathExtension)")
        guard target.lastPathComponent != url.lastPathComponent else {
            return url
        }
        let isCaseOnlyChange = target.lastPathComponent.lowercased() == url.lastPathComponent.lowercased()
        let destination = isCaseOnlyChange ? target : NoteFileNaming.uniqueURL(for: target)
        try FileCoordination.move(from: url, to: destination)
        return destination
    }
}
