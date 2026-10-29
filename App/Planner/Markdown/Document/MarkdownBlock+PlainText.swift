import Foundation

extension MarkdownDocument {
    public var plainText: String {
        blocks.plainText
    }
}

extension Array where Element == MarkdownBlock {
    public var plainText: String {
        map(\.plainText).filter { !$0.isEmpty }.joined(separator: "\n")
    }
}

extension MarkdownBlock {
    public var plainText: String {
        switch self {
        case .heading(_, let content), .paragraph(let content):
            content.plainText
        case .image(let image):
            image.altText
        case .blockQuote(let blocks):
            blocks.plainText
        case .list(let list):
            list.items.map(\.blocks.plainText).joined(separator: "\n")
        case .codeBlock(_, let code):
            code.trimmingCharacters(in: .newlines)
        case .table(let table):
            ([table.header] + table.rows)
                .map { row in row.map(\.plainText).joined(separator: " ") }
                .joined(separator: "\n")
        case .html, .thematicBreak:
            ""
        }
    }
}
