import Foundation

extension MarkdownHighlighter {
    private static let inlineCode = expression(#"(`+)(?!`)(.+?)(?<!`)\1(?!`)"#)
    private static let link = expression(#"!?\[([^\]\n]*)\]\(([^)\n]*)\)"#)
    private static let bold = expression(#"(\*\*|__)(?=\S)(.+?)(?<=\S)\1"#)
    private static let italic = expression(
        #"(?<![*\w])\*(?![*\s])(.+?)(?<![*\s])\*(?![*\w])|(?<![_\w])_(?![_\s])(.+?)(?<![_\s])_(?![_\w])"#
    )
    private static let strikethrough = expression(#"~~(?=\S)(.+?)(?<=\S)~~"#)

    mutating func scanInline(_ range: NSRange) {
        guard range.length > 0 else { return }
        var codeRanges: [NSRange] = []
        for match in matches(of: Self.inlineCode, in: range) {
            let markerLength = match.range(at: 1).length
            add(.inlineCode, match.range)
            add(.syntax, NSRange(location: match.range.location, length: markerLength))
            add(.syntax, NSRange(location: NSMaxRange(match.range) - markerLength, length: markerLength))
            codeRanges.append(match.range)
        }
        let isOutsideCode = { (match: NSTextCheckingResult) in
            !codeRanges.contains { NSIntersectionRange($0, match.range).length > 0 }
        }
        for match in matches(of: Self.link, in: range) where isOutsideCode(match) {
            let label = match.range(at: 1)
            add(.syntax, NSRange(location: match.range.location, length: label.location - match.range.location))
            add(.link, label)
            add(.syntax, NSRange(location: NSMaxRange(label), length: NSMaxRange(match.range) - NSMaxRange(label)))
        }
        for match in matches(of: Self.bold, in: range) where isOutsideCode(match) {
            addWrapped(.bold, match, markerLength: 2)
        }
        for match in matches(of: Self.italic, in: range) where isOutsideCode(match) {
            addWrapped(.italic, match, markerLength: 1)
        }
        for match in matches(of: Self.strikethrough, in: range) where isOutsideCode(match) {
            addWrapped(.strikethrough, match, markerLength: 2)
        }
    }

    private func matches(of expression: NSRegularExpression, in range: NSRange) -> [NSTextCheckingResult] {
        expression.matches(in: text as String, range: range)
    }

    private mutating func addWrapped(_ kind: MarkdownHighlight.Kind, _ match: NSTextCheckingResult, markerLength: Int) {
        add(kind, match.range)
        add(.syntax, NSRange(location: match.range.location, length: markerLength))
        add(.syntax, NSRange(location: NSMaxRange(match.range) - markerLength, length: markerLength))
    }
}
