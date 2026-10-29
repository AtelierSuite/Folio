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
        switch action {
        case .bold: toggledWrapping(with: "**")
        case .italic: toggledWrapping(with: "_")
        case .strikethrough: toggledWrapping(with: "~~")
        case .inlineCode: toggledWrapping(with: "`")
        case .link: insertingLink()
        case .heading: cyclingHeading()
        case .bulletList: toggledLinePrefix(.bullet)
        case .numberedList: toggledLinePrefix(.number)
        case .taskList: toggledLinePrefix(.task)
        case .blockQuote: toggledLinePrefix(.quote)
        case .codeBlock: wrappingInCodeBlock()
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
