import Foundation

extension MarkdownNoteFile {
    /// The note's Markdown without its front matter, which only Folio reads.
    public static func shareableMarkdown(from contents: String) -> String {
        let body = MarkdownNoteFile(contents: contents).body
        return String(body.drop(while: \.isNewline))
    }
}
