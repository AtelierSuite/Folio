import Foundation

public struct MarkdownNoteFile: Sendable, Equatable {
    public var frontMatter: MarkdownFrontMatter
    public var body: String

    public init(frontMatter: MarkdownFrontMatter = MarkdownFrontMatter(), body: String) {
        self.frontMatter = frontMatter
        self.body = body
    }

    public init(contents: String) {
        let lines = contents.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        guard lines.count > 1, lines[0].trimmingSuffix("\r") == Self.openingDelimiter,
              let closingIndex = lines.indices.dropFirst().first(where: {
                  Self.closingDelimiters.contains(lines[$0].trimmingSuffix("\r"))
              }) else {
            self.init(body: contents)
            return
        }
        self.init(
            frontMatter: MarkdownFrontMatter(
                lines: Array(lines[1..<closingIndex]),
                closingDelimiter: lines[closingIndex]
            ),
            body: lines[(closingIndex + 1)...].joined(separator: "\n")
        )
    }

    public var contents: String {
        guard !frontMatter.isEmpty else { return body }
        return ([Self.openingDelimiter] + frontMatter.lines + [frontMatter.closingDelimiter, body])
            .joined(separator: "\n")
    }

    var bodyLineOffset: Int {
        frontMatter.isEmpty ? 0 : frontMatter.lines.count + 2
    }

    static let openingDelimiter = "---"
    static let closingDelimiters = ["---", "..."]
}
