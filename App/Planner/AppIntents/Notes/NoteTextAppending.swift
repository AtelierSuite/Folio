import Foundation

enum NoteTextAppending {
    /// Adds `addition` on a line of its own at the end of `text`.
    static func appending(_ addition: String, to text: String) -> String {
        let addition = addition.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !addition.isEmpty else { return text }
        guard !text.isEmpty else { return "\(addition)\n" }
        let separator = text.hasSuffix("\n") ? "" : "\n"
        return "\(text)\(separator)\(addition)\n"
    }

    /// Swaps the body of a note and keeps its front matter, so links to events and dates survive.
    static func replacingBody(of text: String, with body: String) -> String {
        var file = MarkdownNoteFile(contents: text)
        file.body = body.hasSuffix("\n") || body.isEmpty ? body : "\(body)\n"
        return file.contents
    }
}
