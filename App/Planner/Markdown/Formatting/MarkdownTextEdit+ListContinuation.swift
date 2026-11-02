import Foundation

extension MarkdownTextEdit {
    /// Returns nil when the caret isn't after a list item's marker, so the return key inserts a plain line break.
    public func continuingList() -> MarkdownTextEdit? {
        let characters = Array(text)
        var lineStart = selection.lowerBound
        while lineStart > 0, characters[lineStart - 1] != "\n" { lineStart -= 1 }
        var lineEnd = selection.lowerBound
        while lineEnd < characters.count, characters[lineEnd] != "\n" { lineEnd += 1 }
        let line = substring(lineStart..<lineEnd)
        guard let match = line.prefixMatch(of: Self.listItemMarker) else { return nil }
        let markerLength = line.distance(from: line.startIndex, to: match.range.upperBound)
        guard selection.lowerBound >= lineStart + markerLength else { return nil }
        let content = line[match.range.upperBound...]
        if content.allSatisfy(\.isWhitespace), selection.isEmpty {
            return replacing(lineStart..<lineEnd, with: "", selection: lineStart..<lineStart)
        }
        let continuation = "\n" + match.output.indent + Self.nextMarker(after: match.output.marker)
            + match.output.spacing + (match.output.task == nil ? "" : "[ ] ")
        let caret = selection.lowerBound + continuation.count
        return replacing(selection, with: continuation, selection: caret..<caret)
    }

    private static func nextMarker(after marker: Substring) -> String {
        guard let delimiter = marker.last, let number = Int(marker.dropLast()) else { return String(marker) }
        return "\(number + 1)\(delimiter)"
    }

    private nonisolated(unsafe) static let listItemMarker =
        #/(?<indent>[ \t]*)(?<marker>[-+*]|\d{1,9}[.)])(?<spacing>[ \t]+)(?<task>\[[ xX]\](?:[ \t]+|$))?/#
}
