#if os(iOS)
import SwiftUI
import UIKit

extension MarkdownTextView: UIViewRepresentable {
    func makeUIView(context: Context) -> MarkdownUITextView {
        let textView = MarkdownUITextView(frame: .zero, textContainer: nil)
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.allowsEditingTextAttributes = false
        textView.adjustsFontForContentSizeCategory = true
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.alwaysBounceVertical = true
        textView.keyboardDismissMode = .interactive
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 24, right: 12)
        textView.typingAttributes = MarkdownTextStyler.baseAttributes
        context.coordinator.attach(textView)
        if focusesOnAppear {
            Task { @MainActor in
                textView.becomeFirstResponder()
            }
        }
        return textView
    }

    func updateUIView(_ textView: MarkdownUITextView, context: Context) {
        context.coordinator.update(text: $text, baseURL: baseURL)
        if textView.contentInset.bottom != bottomInset {
            textView.contentInset.bottom = bottomInset
            textView.verticalScrollIndicatorInsets.bottom = bottomInset
        }
    }
}

final class MarkdownUITextView: UITextView, MarkdownTextHost {
    private let textUndoManager = UndoManager()

    override var undoManager: UndoManager? {
        textUndoManager
    }

    var markdownStorage: NSTextStorage {
        textStorage
    }

    var markdownSelection: NSRange {
        get { selectedRange }
        set { selectedRange = newValue }
    }

    var markdownUndoManager: UndoManager {
        textUndoManager
    }

    func prepareForProgrammaticEdit() {}

    func focusMarkdownText() {
        becomeFirstResponder()
    }
}

extension MarkdownTextCoordinator: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard textView.markedTextRange == nil else { return }
        textDidChange()
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.typingAttributes[.attachment] != nil {
            textView.typingAttributes[.attachment] = nil
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        setEditing(true)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        setEditing(false)
    }
}
#endif
