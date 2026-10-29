import Foundation

extension MarkdownTextEdit {
    func toggledWrapping(with marker: String) -> MarkdownTextEdit {
        let length = marker.count
        let selected = substring(selection)
        let before = substring(max(0, selection.lowerBound - length)..<selection.lowerBound)
        let after = substring(selection.upperBound..<min(text.count, selection.upperBound + length))
        if !selected.isEmpty, before == marker, after == marker {
            let outer = (selection.lowerBound - length)..<(selection.upperBound + length)
            let newStart = selection.lowerBound - length
            return replacing(outer, with: selected, selection: newStart..<(newStart + selected.count))
        }
        if selected.count >= length * 2, selected.hasPrefix(marker), selected.hasSuffix(marker) {
            let inner = String(selected.dropFirst(length).dropLast(length))
            return replacing(selection, with: inner, selection: selection.lowerBound..<(selection.lowerBound + inner.count))
        }
        let newSelection = (selection.lowerBound + length)..<(selection.upperBound + length)
        return replacing(selection, with: marker + selected + marker, selection: newSelection)
    }

    func insertingLink() -> MarkdownTextEdit {
        let selected = substring(selection)
        let placeholder = "https://"
        let replacement = "[\(selected)](\(placeholder))"
        let urlStart = selection.lowerBound + selected.count + 3
        let newSelection = selected.isEmpty
            ? (selection.lowerBound + 1)..<(selection.lowerBound + 1)
            : urlStart..<(urlStart + placeholder.count)
        return replacing(selection, with: replacement, selection: newSelection)
    }

    func wrappingInCodeBlock() -> MarkdownTextEdit {
        let lines = lineRange
        let selected = substring(lines)
        let fence = "```"
        let prefix = lines.lowerBound > 0 && substring((lines.lowerBound - 1)..<lines.lowerBound) != "\n" ? "\n" : ""
        let replacement = "\(prefix)\(fence)\n\(selected)\n\(fence)"
        let contentStart = lines.lowerBound + prefix.count + fence.count + 1
        return replacing(lines, with: replacement, selection: contentStart..<(contentStart + selected.count))
    }
}
