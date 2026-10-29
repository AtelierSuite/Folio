import Planner
import SwiftUI

struct MarkdownSourceEditor: View {
    @Binding var text: String
    @State private var selection: TextSelection?

    var body: some View {
        VStack(spacing: 0) {
            MarkdownFormattingBar(perform: apply)
            Divider()
            TextEditor(text: $text, selection: $selection)
                .font(.body.monospaced())
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 8)
        }
    }

    private func apply(_ action: MarkdownFormattingAction) {
        let edit = MarkdownTextEdit(text: text, selection: selectedOffsets).applying(action)
        text = edit.text
        let lowerBound = text.index(text.startIndex, offsetBy: edit.selection.lowerBound)
        let upperBound = text.index(text.startIndex, offsetBy: edit.selection.upperBound)
        selection = TextSelection(range: lowerBound..<upperBound)
    }

    private var selectedOffsets: Range<Int> {
        guard case .selection(let range) = selection?.indices,
              range.lowerBound >= text.startIndex, range.upperBound <= text.endIndex else {
            return text.count..<text.count
        }
        let lowerBound = text.distance(from: text.startIndex, to: range.lowerBound)
        return lowerBound..<(lowerBound + text.distance(from: range.lowerBound, to: range.upperBound))
    }
}
