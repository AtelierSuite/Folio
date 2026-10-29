import Foundation

extension MarkdownTextEdit {
    enum LinePrefix {
        case bullet
        case number
        case task
        case quote

        func text(forLineAt position: Int) -> String {
            switch self {
            case .bullet: "- "
            case .number: "\(position + 1). "
            case .task: "- [ ] "
            case .quote: "> "
            }
        }

        var pattern: Regex<Substring> {
            switch self {
            case .bullet: #/[-+*] (?!\[[ xX]\] )/#
            case .number: #/\d{1,9}[.)] /#
            case .task: #/[-+*] \[[ xX]\] /#
            case .quote: #/> ?/#
            }
        }

        var isListMarker: Bool {
            self != .quote
        }
    }

    var lineRange: Range<Int> {
        let characters = Array(text)
        var start = selection.lowerBound
        while start > 0, characters[start - 1] != "\n" { start -= 1 }
        var end = selection.upperBound
        while end < characters.count, characters[end] != "\n" { end += 1 }
        return start..<end
    }

    func toggledLinePrefix(_ prefix: LinePrefix) -> MarkdownTextEdit {
        let range = lineRange
        let lines = substring(range).split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let contentLines = lines.filter { !$0.isEmpty }
        let isRemoving = !contentLines.isEmpty && contentLines.allSatisfy { $0.prefixMatch(of: prefix.pattern) != nil }
        let listPatterns: [LinePrefix] = [.task, .bullet, .number]
        var position = 0
        let newLines = lines.map { line -> String in
            if let match = line.prefixMatch(of: prefix.pattern), isRemoving {
                return String(line[match.range.upperBound...])
            }
            guard !line.isEmpty || lines.count == 1 else { return line }
            var content = Substring(line)
            if prefix.isListMarker,
               let match = listPatterns.lazy.compactMap({ line.prefixMatch(of: $0.pattern) }).first {
                content = line[match.range.upperBound...]
            }
            defer { position += 1 }
            return prefix.text(forLineAt: position) + content
        }
        return replacingLines(range, original: lines, with: newLines)
    }

    func cyclingHeading() -> MarkdownTextEdit {
        let range = lineRange
        let lines = substring(range).split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let newLines = lines.map { line -> String in
            let level = line.prefixMatch(of: #/#{1,6} /#).map { $0.output.count - 1 } ?? 0
            let content = line.dropFirst(level == 0 ? 0 : level + 1)
            return level >= 3 ? String(content) : String(repeating: "#", count: level + 1) + " " + content
        }
        return replacingLines(range, original: lines, with: newLines)
    }

    private func replacingLines(_ range: Range<Int>, original: [String], with lines: [String]) -> MarkdownTextEdit {
        let replacement = lines.joined(separator: "\n")
        if original.count == 1, selection.isEmpty {
            let delta = replacement.count - original[0].count
            let cursor = max(range.lowerBound, min(selection.lowerBound + delta, range.lowerBound + replacement.count))
            return replacing(range, with: replacement, selection: cursor..<cursor)
        }
        return replacing(range, with: replacement, selection: range.lowerBound..<(range.lowerBound + replacement.count))
    }
}
