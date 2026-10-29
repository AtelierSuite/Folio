import Foundation

public enum MarkdownFormattingAction: String, Sendable, CaseIterable {
    case heading
    case bold
    case italic
    case strikethrough
    case inlineCode
    case link
    case bulletList
    case numberedList
    case taskList
    case blockQuote
    case codeBlock
}
