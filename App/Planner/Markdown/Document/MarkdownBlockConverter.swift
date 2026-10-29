import Foundation
import Markdown

struct MarkdownBlockConverter {
    let lineOffset: Int

    func blocks(from children: some Sequence<Markup>) -> [MarkdownBlock] {
        children.compactMap(block)
    }

    private func block(from markup: Markup) -> MarkdownBlock? {
        switch markup {
        case let heading as Heading:
            .heading(level: heading.level, content: MarkdownInlineConverter.inlines(from: heading.children))
        case let paragraph as Paragraph:
            self.paragraph(paragraph)
        case let quote as BlockQuote:
            .blockQuote(blocks(from: quote.children))
        case let list as UnorderedList:
            .list(MarkdownList(isOrdered: false, startIndex: 1, items: list.listItems.map(listItem)))
        case let list as OrderedList:
            .list(MarkdownList(isOrdered: true, startIndex: Int(list.startIndex), items: list.listItems.map(listItem)))
        case let codeBlock as CodeBlock:
            .codeBlock(language: codeBlock.language, code: codeBlock.code.trimmingSuffix("\n"))
        case let table as Markdown.Table:
            .table(self.table(table))
        case let html as HTMLBlock:
            .html(html.rawHTML.trimmingSuffix("\n"))
        case is ThematicBreak:
            .thematicBreak
        default:
            nil
        }
    }

    private func paragraph(_ paragraph: Paragraph) -> MarkdownBlock {
        let inlines = MarkdownInlineConverter.inlines(from: paragraph.children)
        if inlines.count == 1, case .image(let image) = inlines[0] {
            return .image(image)
        }
        return .paragraph(inlines)
    }

    private func listItem(_ item: ListItem) -> MarkdownListItem {
        let checkbox: MarkdownCheckbox? = switch item.checkbox {
        case .checked: .checked
        case .unchecked: .unchecked
        case nil: nil
        }
        return MarkdownListItem(
            checkbox: checkbox,
            blocks: blocks(from: item.children),
            sourceLine: (item.range?.lowerBound.line ?? 0) + lineOffset
        )
    }

    private func table(_ table: Markdown.Table) -> MarkdownTable {
        MarkdownTable(
            columnAlignments: table.columnAlignments.map { alignment in
                switch alignment {
                case .center: .center
                case .right: .trailing
                case .left, nil: .leading
                }
            },
            header: table.head.cells.map { MarkdownInlineConverter.inlines(from: $0.children) },
            rows: table.body.rows.map { row in
                row.cells.map { MarkdownInlineConverter.inlines(from: $0.children) }
            }
        )
    }
}

extension String {
    func trimmingSuffix(_ suffix: String) -> String {
        hasSuffix(suffix) ? String(dropLast(suffix.count)) : self
    }
}
