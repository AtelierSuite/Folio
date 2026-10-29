import Foundation

public indirect enum MarkdownBlock: Sendable, Equatable {
    case heading(level: Int, content: [MarkdownInline])
    case paragraph([MarkdownInline])
    case image(MarkdownImage)
    case blockQuote([MarkdownBlock])
    case list(MarkdownList)
    case codeBlock(language: String?, code: String)
    case table(MarkdownTable)
    case html(String)
    case thematicBreak
}

public struct MarkdownImage: Sendable, Equatable {
    public let source: String
    public let altText: String
    public let title: String?

    public init(source: String, altText: String, title: String?) {
        self.source = source
        self.altText = altText
        self.title = title
    }
}
