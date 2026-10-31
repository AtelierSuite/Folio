import Foundation

/// Finds the ranges a live Markdown editor styles, line by line, without changing the text.
public struct MarkdownHighlighter {
    let text: NSString
    var highlights: [MarkdownHighlight] = []

    public static func highlights(in text: String) -> [MarkdownHighlight] {
        var highlighter = MarkdownHighlighter(text: text as NSString)
        highlighter.scan()
        return highlighter.highlights
    }

    mutating func add(_ kind: MarkdownHighlight.Kind, _ range: NSRange) {
        guard range.length > 0 else { return }
        highlights.append(MarkdownHighlight(kind, range))
    }

    private mutating func scan() {
        let lines = lineRanges()
        var index = scanFrontMatter(lines)
        var openFence: String?
        var fenceStart = 0
        while index < lines.count {
            let line = lines[index]
            let content = text.substring(with: line)
            let trimmed = content.trimmingCharacters(in: .whitespaces)
            if let fence = openFence {
                if trimmed.hasPrefix(fence) {
                    add(.syntax, line)
                    add(.codeBlock, NSRange(location: fenceStart, length: NSMaxRange(line) - fenceStart))
                    openFence = nil
                }
            } else if let fence = Self.fence(of: trimmed) {
                openFence = fence
                fenceStart = line.location
                add(.syntax, line)
            } else {
                scanLine(line)
            }
            index += 1
        }
        if openFence != nil {
            add(.codeBlock, NSRange(location: fenceStart, length: text.length - fenceStart))
        }
    }

    private mutating func scanFrontMatter(_ lines: [NSRange]) -> Int {
        guard lines.count > 1, text.substring(with: lines[0]) == "---" else { return 0 }
        for index in lines.indices.dropFirst() where ["---", "..."].contains(text.substring(with: lines[index])) {
            add(.frontMatter, NSRange(location: 0, length: NSMaxRange(lines[index])))
            return index + 1
        }
        return 0
    }

    private func lineRanges() -> [NSRange] {
        var ranges: [NSRange] = []
        var location = 0
        while location <= text.length {
            let remaining = NSRange(location: location, length: text.length - location)
            let newline = text.range(of: "\n", range: remaining)
            let end = newline.location == NSNotFound ? text.length : newline.location
            var lineRange = NSRange(location: location, length: end - location)
            if lineRange.length > 0, text.character(at: NSMaxRange(lineRange) - 1) == 13 {
                lineRange.length -= 1
            }
            ranges.append(lineRange)
            guard newline.location != NSNotFound else { break }
            location = end + 1
        }
        return ranges
    }

    private static func fence(of trimmedLine: String) -> String? {
        ["```", "~~~"].first { trimmedLine.hasPrefix($0) }
    }
}

extension MarkdownHighlighter {
    static func expression(_ pattern: String) -> NSRegularExpression {
        // swiftlint:disable:next force_try
        try! NSRegularExpression(pattern: pattern)
    }
}
