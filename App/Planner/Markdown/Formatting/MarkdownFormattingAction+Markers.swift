import Foundation

extension MarkdownFormattingAction {
    var wrappingMarker: String? {
        switch self {
        case .bold: "**"
        case .italic: "_"
        case .strikethrough: "~~"
        case .inlineCode: "`"
        default: nil
        }
    }

    var linePrefix: MarkdownTextEdit.LinePrefix? {
        switch self {
        case .bulletList: .bullet
        case .numberedList: .number
        case .taskList: .task
        case .blockQuote: .quote
        default: nil
        }
    }
}
