#if os(macOS)
import AppKit
import SwiftUI

extension MarkdownTextView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSScrollView {
        let textView = MarkdownNSTextView(usingTextLayoutManager: true)
        textView.delegate = context.coordinator
        textView.drawsBackground = false
        textView.isRichText = true
        textView.importsGraphics = false
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.textContainerInset = NSSize(width: 12, height: 16)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.minSize = .zero
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        textView.typingAttributes = MarkdownTextStyler.baseAttributes
        textView.onFocusChange = { [weak coordinator = context.coordinator] isFocused in
            coordinator?.setEditing(isFocused)
        }
        textView.onToggleTask = { [weak coordinator = context.coordinator] range in
            coordinator?.toggleTask(markerRange: range)
        }
        let scrollView = NSScrollView()
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.automaticallyAdjustsContentInsets = false
        scrollView.documentView = textView
        context.coordinator.attach(textView)
        if focusesOnAppear {
            Task { @MainActor in
                textView.focusMarkdownText()
            }
        }
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        context.coordinator.update(text: $text, baseURL: baseURL)
        if scrollView.contentInsets.bottom != bottomInset {
            scrollView.contentInsets.bottom = bottomInset
        }
    }
}

final class MarkdownNSTextView: NSTextView, MarkdownTextHost {
    var onFocusChange: ((Bool) -> Void)?
    var onToggleTask: ((NSRange) -> Void)?
    var listDecorations: [MarkdownListDecoration] = []
    var decorationViews: [NSView] = []
    private let textUndoManager = UndoManager()

    override func setFrameSize(_ newSize: NSSize) {
        let sizeChanged = newSize != frame.size
        super.setFrameSize(newSize)
        if sizeChanged {
            layoutListDecorations()
        }
    }

    func showListDecorations(_ decorations: [MarkdownListDecoration]) {
        listDecorations = decorations
        layoutListDecorations()
    }

    override var undoManager: UndoManager? {
        textUndoManager
    }

    override func becomeFirstResponder() -> Bool {
        let didBecome = super.becomeFirstResponder()
        if didBecome {
            onFocusChange?(true)
        }
        return didBecome
    }

    override func resignFirstResponder() -> Bool {
        let didResign = super.resignFirstResponder()
        if didResign {
            onFocusChange?(false)
        }
        return didResign
    }

    /// The window's undo manager also holds the app's undo steps, so the text keeps its own and the
    /// Edit menu's Undo and Redo, which go to the window by default, are taken here first.
    @objc func undo(_ sender: Any?) {
        textUndoManager.undo()
    }

    @objc func redo(_ sender: Any?) {
        textUndoManager.redo()
    }

    override func validateUserInterfaceItem(_ item: any NSValidatedUserInterfaceItem) -> Bool {
        switch item.action {
        case #selector(undo(_:)): textUndoManager.canUndo
        case #selector(redo(_:)): textUndoManager.canRedo
        default: super.validateUserInterfaceItem(item)
        }
    }

    override func paste(_ sender: Any?) {
        pasteAsPlainText(sender)
    }

    var markdownStorage: NSTextStorage {
        textStorage ?? NSTextStorage()
    }

    var markdownSelection: NSRange {
        get { selectedRange() }
        set { setSelectedRange(newValue) }
    }

    var markdownUndoManager: UndoManager {
        textUndoManager
    }

    func prepareForProgrammaticEdit() {
        breakUndoCoalescing()
    }

    func focusMarkdownText() {
        window?.makeFirstResponder(self)
    }
}

extension MarkdownTextCoordinator: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView, !textView.hasMarkedText() else { return }
        textDidChange()
    }

    func textViewDidChangeSelection(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView, !textView.hasMarkedText() else { return }
        selectionDidChange()
        if textView.typingAttributes[.attachment] != nil || Self.isHidden(textView.typingAttributes) {
            textView.typingAttributes = MarkdownTextStyler.baseAttributes
        }
    }
}
#endif
