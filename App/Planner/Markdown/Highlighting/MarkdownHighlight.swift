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
        /// The whole marker of a `-`, `*` or `+` item that isn't a task, which an editor can draw as a bullet.
        case bullet
        /// The whole marker of a task item, `- [ ] ` included, which an editor can draw as a checkbox.
        case task(isChecked: Bool)
        case horizontalRule
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
