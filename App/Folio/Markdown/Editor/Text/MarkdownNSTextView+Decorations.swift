#if os(macOS)
import AppKit

extension MarkdownNSTextView {
    func layoutListDecorations() {
        decorationViews.forEach { $0.removeFromSuperview() }
        guard let textLayoutManager, !listDecorations.isEmpty else {
            decorationViews = []
            return
        }
        textLayoutManager.ensureLayout(for: textLayoutManager.documentRange)
        let origin = textContainerOrigin
        let lineWidth = bounds.width - (textContainerInset.width * 2)
        decorationViews = listDecorations.compactMap { decoration in
            guard let lineFrame = textLayoutManager.frame(ofCharacterRange: decoration.range) else { return nil }
            let view = decorationView(for: decoration)
            view.frame = decoration.frame(inLine: lineFrame, origin: origin, lineWidth: lineWidth)
            addSubview(view)
            return view
        }
    }

    private func decorationView(for decoration: MarkdownListDecoration) -> NSView {
        let configuration = NSImage.SymbolConfiguration(
            pointSize: MarkdownEditorStyle.bodyFont.pointSize,
            weight: .regular
        )
        let image = NSImage(
            systemSymbolName: decoration.symbolName,
            accessibilityDescription: decoration.accessibilityLabel
        )?.withSymbolConfiguration(configuration)
        if decoration.kind == .rule {
            let line = NSView()
            line.wantsLayer = true
            line.layer?.backgroundColor = MarkdownEditorStyle.separatorColor.cgColor
            return line
        }
        guard case .task = decoration.kind else {
            let imageView = NSImageView()
            imageView.image = image
            imageView.contentTintColor = decoration.tintColor
            imageView.imageScaling = .scaleProportionallyUpOrDown
            return imageView
        }
        let button = MarkdownTaskButton(range: decoration.range) { [weak self] range in
            self?.onToggleTask?(range)
        }
        button.image = image
        button.contentTintColor = decoration.tintColor
        button.setAccessibilityLabel(decoration.accessibilityLabel)
        return button
    }
}

final class MarkdownTaskButton: NSButton {
    private let range: NSRange
    private let onToggle: (NSRange) -> Void

    init(range: NSRange, onToggle: @escaping (NSRange) -> Void) {
        self.range = range
        self.onToggle = onToggle
        super.init(frame: .zero)
        isBordered = false
        imageScaling = .scaleProportionallyUpOrDown
        title = ""
        target = self
        action = #selector(toggle)
    }

    required init?(coder: NSCoder) {
        nil
    }

    @objc private func toggle() {
        onToggle(range)
    }
}
#endif
