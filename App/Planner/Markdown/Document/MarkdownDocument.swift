import Foundation
import Markdown

public struct MarkdownDocument: Sendable, Equatable {
    public let frontMatter: MarkdownFrontMatter
    public let blocks: [MarkdownBlock]

    public init(frontMatter: MarkdownFrontMatter = MarkdownFrontMatter(), blocks: [MarkdownBlock]) {
        self.frontMatter = frontMatter
        self.blocks = blocks
    }

    public init(parsing contents: String) {
        let file = MarkdownNoteFile(contents: contents)
        let document = Document(parsing: file.body, options: [.disableSmartOpts])
        let converter = MarkdownBlockConverter(lineOffset: file.bodyLineOffset)
        self.init(frontMatter: file.frontMatter, blocks: converter.blocks(from: document.children))
    }
}
