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
        textView.onToggleTask = { [weak coordinator = context.coordinator] range in
            coordinator?.toggleTask(markerRange: range)
        }
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
        textView.onPasteImage = onPasteImage
        if textView.contentInset.bottom != bottomInset {
            textView.contentInset.bottom = bottomInset
            textView.verticalScrollIndicatorInsets.bottom = bottomInset
        }
    }
}

final class MarkdownUITextView: UITextView, MarkdownTextHost {
    private let textUndoManager = UndoManager()
    var onToggleTask: ((NSRange) -> Void)?
    var onPasteImage: ((MarkdownPastedImage) -> Void)?
    var listDecorations: [MarkdownListDecoration] = []
    var decorationViews: [UIView] = []
    private var decoratedSize = CGSize.zero

    override func layoutSubviews() {
        super.layoutSubviews()
        let size = CGSize(width: bounds.width, height: contentSize.height)
        if size != decoratedSize {
            decoratedSize = size
            layoutListDecorations()
        }
    }

    /// Text views that don't edit text attributes only paste text, so an image on the pasteboard is taken here.
    override func paste(_ sender: Any?) {
        if let onPasteImage, let image = MarkdownPastedImage.fromPasteboard() {
            onPasteImage(image)
        } else {
            super.paste(sender)
        }
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)), onPasteImage != nil, MarkdownPastedImage.isAvailable {
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }

    func showListDecorations(_ decorations: [MarkdownListDecoration]) {
        listDecorations = decorations
        layoutListDecorations()
    }

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
        guard textView.markedTextRange == nil else { return }
        selectionDidChange()
        if textView.typingAttributes[.attachment] != nil || Self.isHidden(textView.typingAttributes) {
            textView.typingAttributes = MarkdownTextStyler.baseAttributes
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
