import Foundation

extension SearchDocument {
    public init(note file: NoteFile, text: String?) {
        let markdown = text.map(MarkdownNoteFile.init(contents:))
        let body = markdown?.body ?? ""
        let frontMatterText = markdown?.frontMatter.lines.joined(separator: "\n") ?? ""
        self.init(
            id: Self.noteID(for: file.url),
            kind: .note,
            title: file.title,
            detail: file.folderPath.isEmpty ? nil : file.folderPath,
            body: [body, frontMatterText].filter { !$0.isEmpty }.joined(separator: "\n"),
            date: markdown?.frontMatter.date ?? file.modifiedDate,
            hasMeetingLink: MeetingLink.isPresent(in: [text]),
            destination: .note(file.url)
        )
    }
}

extension SearchDocument {
    static func noteID(for url: URL) -> String {
        "note:\(url.standardizedFileURL.path(percentEncoded: false))"
    }
}
