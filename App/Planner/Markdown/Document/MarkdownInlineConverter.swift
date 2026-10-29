import Foundation
import Markdown

enum MarkdownInlineConverter {
    static func inlines(from children: some Sequence<Markup>) -> [MarkdownInline] {
        children.compactMap(inline)
    }

    private static func inline(from markup: Markup) -> MarkdownInline? {
        switch markup {
        case let text as Markdown.Text:
            .text(text.string)
        case let emphasis as Emphasis:
            .emphasis(inlines(from: emphasis.children))
        case let strong as Strong:
            .strong(inlines(from: strong.children))
        case let strikethrough as Strikethrough:
            .strikethrough(inlines(from: strikethrough.children))
        case let code as InlineCode:
            .code(code.code)
        case let link as Markdown.Link:
            .link(destination: link.destination, content: inlines(from: link.children))
        case let image as Markdown.Image:
            .image(MarkdownImage(
                source: image.source ?? "",
                altText: inlines(from: image.children).plainText,
                title: image.title
            ))
        case let html as InlineHTML:
            .html(html.rawHTML)
        case is SoftBreak:
            .softBreak
        case is LineBreak:
            .lineBreak
        case let symbolLink as SymbolLink:
            .code(symbolLink.destination ?? "")
        default:
            .text(markup.format())
        }
    }
}
