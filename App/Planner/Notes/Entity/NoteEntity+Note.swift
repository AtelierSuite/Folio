import Foundation

extension NoteEntity {
    public init(note: Note, relativePath: String) {
        let document = MarkdownDocument(parsing: note.text)
        self.init(
            id: relativePath,
            url: note.url,
            title: note.title,
            plainText: document.plainText,
            tags: document.frontMatter.tags,
            date: document.frontMatter.date,
            modifiedDate: note.modifiedDate
        )
    }

    public init(placeholderFor file: NoteFile) {
        self.init(id: file.relativePath, url: file.url, title: file.title, modifiedDate: file.modifiedDate)
    }
}

extension NoteFileStore {
    /// Reads without downloading evicted files or resolving conflicts, so indexing never changes the library.
    @concurrent
    public func entity(for file: NoteFile) async -> NoteEntity {
        guard file.isDownloaded,
              let note = try? FileCoordination.read(at: file.url, { coordinatedURL in
                  try loadNote(at: coordinatedURL, reportedURL: file.url)
              }) else {
            return NoteEntity(placeholderFor: file)
        }
        return NoteEntity(note: note, relativePath: file.relativePath)
    }
}
