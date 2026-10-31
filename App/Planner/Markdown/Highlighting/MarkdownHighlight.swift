import Foundation

public struct MarkdownHighlight: Hashable, Sendable {
    public enum Kind: Hashable, Sendable {
        case frontMatter
        case heading(level: Int)
        case bold
        case italic
        case strikethrough
        case inlineCode
        case codeBlock
        case blockQuote
        case link
        case listMarker
        case completedTask
        case syntax
    }

    public let kind: Kind
    /// UTF-16 range, ready for `NSAttributedString`.
    public let range: NSRange

    public init(_ kind: Kind, _ range: NSRange) {
        self.kind = kind
        self.range = range
    }
}
