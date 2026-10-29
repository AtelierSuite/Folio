import Foundation

public struct MarkdownTextEdit: Sendable, Equatable {
    public var text: String
    public var selection: Range<Int>

    public init(text: String, selection: Range<Int>) {
        self.text = text
        let upperBound = min(selection.upperBound, text.count)
        self.selection = min(selection.lowerBound, upperBound)..<upperBound
    }

    public func applying(_ action: MarkdownFormattingAction) -> MarkdownTextEdit {
        if let marker = action.wrappingMarker {
            return toggledWrapping(with: marker)
        }
        if let prefix = action.linePrefix {
            return toggledLinePrefix(prefix)
        }
        return switch action {
        case .link: insertingLink()
        case .heading: cyclingHeading()
        case .codeBlock: wrappingInCodeBlock()
        default: self
        }
    }

    func index(_ offset: Int) -> String.Index {
        text.index(text.startIndex, offsetBy: offset)
    }

    func substring(_ range: Range<Int>) -> String {
        String(text[index(range.lowerBound)..<index(range.upperBound)])
    }

    func replacing(_ range: Range<Int>, with replacement: String, selection: Range<Int>) -> MarkdownTextEdit {
        var newText = text
        newText.replaceSubrange(index(range.lowerBound)..<index(range.upperBound), with: replacement)
        return MarkdownTextEdit(text: newText, selection: selection)
    }
}
