import Foundation

extension LinkedNoteIndex {
    public func updated(with files: [NoteFile], in store: NoteFileStore) async -> LinkedNoteIndex {
        var index = LinkedNoteIndex()
        for file in files {
            if let known = notes[file.url], known.file == file {
                index.insert(known)
            } else {
                index.insert(await store.linkedNote(for: file))
            }
        }
        return index
    }
}

extension NoteFileStore {
    /// Reads without downloading evicted files or resolving conflicts, like Spotlight indexing.
    @concurrent
    func linkedNote(for file: NoteFile) async -> LinkedNote {
        guard file.isDownloaded else {
            return LinkedNote(file: file)
        }
        let note = try? FileCoordination.read(at: file.url) { coordinatedURL in
            try loadNote(at: coordinatedURL, reportedURL: file.url)
        }
        return LinkedNote(file: file, text: note?.text)
    }
}
