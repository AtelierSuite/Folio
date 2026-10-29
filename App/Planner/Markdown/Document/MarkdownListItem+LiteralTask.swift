import Foundation

extension MarkdownListItem {
    // cmark-gfm's tasklist extension misses task items nested in block quotes, leaving "[ ] " as text.
    init?(literalTaskBlocks blocks: [MarkdownBlock], sourceLine: Int) {
        guard case .paragraph(var inlines) = blocks.first, case .text(let text) = inlines.first,
              let match = text.prefixMatch(of: #/\[(?<state>[ xX])\][ \t]+/#) else { return nil }
        let remainder = String(text[match.range.upperBound...])
        if remainder.isEmpty {
            inlines.removeFirst()
        } else {
            inlines[0] = .text(remainder)
        }
        self.init(
            checkbox: match.output.state == " " ? .unchecked : .checked,
            blocks: [.paragraph(inlines)] + blocks.dropFirst(),
            sourceLine: sourceLine
        )
    }
}
