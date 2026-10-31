import Foundation

extension MarkdownHighlighter {
    private static let heading = expression(#"^(#{1,6})(?:[ \t]+|$)"#)
    private static let horizontalRule = expression(#"^ {0,3}([-*_])(?:[ \t]*\1){2,}[ \t]*$"#)
    private static let blockQuote = expression(#"^[ \t]*(?:>[ \t]?)+"#)
    private static let listItem = expression(
        #"^[ \t]*(?:[-*+]|\d{1,9}[.)])[ \t]+(\[[ xX]\](?:[ \t]+|$))?"#
    )

    mutating func scanLine(_ line: NSRange) {
        if let match = Self.heading.firstMatch(in: text as String, range: line) {
            let level = match.range(at: 1).length
            add(.heading(level: level), line)
            add(.syntax, match.range(at: 1))
            scanInline(NSRange(location: NSMaxRange(match.range), length: NSMaxRange(line) - NSMaxRange(match.range)))
            return
        }
        if Self.horizontalRule.firstMatch(in: text as String, range: line) != nil {
            add(.syntax, line)
            return
        }
        var contentStart = line.location
        if let match = Self.blockQuote.firstMatch(in: text as String, range: line) {
            add(.blockQuote, line)
            add(.syntax, match.range)
            contentStart = NSMaxRange(match.range)
        }
        let rest = NSRange(location: contentStart, length: NSMaxRange(line) - contentStart)
        if let match = Self.listItem.firstMatch(in: text as String, range: rest) {
            add(.listMarker, match.range)
            contentStart = NSMaxRange(match.range)
            let checkbox = match.range(at: 1)
            if checkbox.location != NSNotFound, text.substring(with: checkbox).lowercased().hasPrefix("[x]") {
                add(.completedTask, NSRange(location: contentStart, length: NSMaxRange(line) - contentStart))
            }
        }
        scanInline(NSRange(location: contentStart, length: NSMaxRange(line) - contentStart))
    }
}
