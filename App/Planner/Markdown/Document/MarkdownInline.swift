import Foundation

public indirect enum MarkdownInline: Sendable, Equatable {
    case text(String)
    case emphasis([MarkdownInline])
    case strong([MarkdownInline])
    case strikethrough([MarkdownInline])
    case code(String)
    case link(destination: String?, content: [MarkdownInline])
    case image(MarkdownImage)
    case html(String)
    case softBreak
    case lineBreak
}

extension Array where Element == MarkdownInline {
    public var plainText: String {
        map(\.plainText).joined()
    }
}

extension MarkdownInline {
    public var plainText: String {
        switch self {
        case .text(let text), .code(let text), .html(let text):
            text
        case .emphasis(let children), .strong(let children), .strikethrough(let children):
            children.plainText
        case .link(_, let content):
            content.plainText
        case .image(let image):
            image.altText
        case .softBreak:
            " "
        case .lineBreak:
            "\n"
        }
    }
}
