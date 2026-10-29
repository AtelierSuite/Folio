import Foundation
import Planner

extension MarkdownFormattingAction {
    var title: String {
        switch self {
        case .heading: String(localized: "Format.Heading", table: "Markdown")
        case .bold: String(localized: "Format.Bold", table: "Markdown")
        case .italic: String(localized: "Format.Italic", table: "Markdown")
        case .strikethrough: String(localized: "Format.Strikethrough", table: "Markdown")
        case .inlineCode: String(localized: "Format.InlineCode", table: "Markdown")
        case .link: String(localized: "Format.Link", table: "Markdown")
        case .bulletList: String(localized: "Format.BulletList", table: "Markdown")
        case .numberedList: String(localized: "Format.NumberedList", table: "Markdown")
        case .taskList: String(localized: "Format.TaskList", table: "Markdown")
        case .blockQuote: String(localized: "Format.BlockQuote", table: "Markdown")
        case .codeBlock: String(localized: "Format.CodeBlock", table: "Markdown")
        }
    }

    var systemImage: String {
        switch self {
        case .heading: "number"
        case .bold: "bold"
        case .italic: "italic"
        case .strikethrough: "strikethrough"
        case .inlineCode: "chevron.left.forwardslash.chevron.right"
        case .link: "link"
        case .bulletList: "list.bullet"
        case .numberedList: "list.number"
        case .taskList: "checklist"
        case .blockQuote: "text.quote"
        case .codeBlock: "curlybraces"
        }
    }
}
