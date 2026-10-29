import Planner
import SwiftUI

struct MarkdownBlockView: View {
    let block: MarkdownBlock

    var body: some View {
        switch block {
        case .heading(let level, let content):
            MarkdownInlineText(inlines: content)
                .font(MarkdownHeadingFont.font(forLevel: level))
                .padding(.top, level <= 2 ? 8 : 4)
        case .paragraph(let content):
            MarkdownInlineText(inlines: content)
        case .image(let image):
            MarkdownImageView(image: image)
        case .blockQuote(let blocks):
            MarkdownBlockQuoteView(blocks: blocks)
        case .list(let list):
            MarkdownListView(list: list)
        case .codeBlock(let language, let code):
            MarkdownCodeBlockView(language: language, code: code)
        case .table(let table):
            MarkdownTableView(table: table)
        case .html(let html):
            MarkdownCodeBlockView(language: nil, code: html)
        case .thematicBreak:
            Divider()
        }
    }
}
