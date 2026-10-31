#if os(iOS)
import UIKit

extension MarkdownUITextView {
    func layoutListDecorations() {
        decorationViews.forEach { $0.removeFromSuperview() }
        guard let textLayoutManager, !listDecorations.isEmpty else {
            decorationViews = []
            return
        }
        textLayoutManager.ensureLayout(for: textLayoutManager.documentRange)
        let origin = CGPoint(x: textContainerInset.left, y: textContainerInset.top)
        let lineWidth = bounds.width - (textContainerInset.left + textContainerInset.right)
        decorationViews = listDecorations.compactMap { decoration in
            guard let lineFrame = textLayoutManager.frame(ofCharacterRange: decoration.range) else { return nil }
            let view = decorationView(for: decoration)
            view.frame = decoration.frame(inLine: lineFrame, origin: origin, lineWidth: lineWidth)
            addSubview(view)
            return view
        }
    }

    private func decorationView(for decoration: MarkdownListDecoration) -> UIView {
        let configuration = UIImage.SymbolConfiguration(pointSize: MarkdownEditorStyle.bodyFont.pointSize)
        let image = UIImage(systemName: decoration.symbolName, withConfiguration: configuration)
        if decoration.kind == .rule {
            let line = UIView()
            line.backgroundColor = MarkdownEditorStyle.separatorColor
            return line
        }
        guard case .task = decoration.kind else {
            let imageView = UIImageView(image: image)
            imageView.tintColor = decoration.tintColor
            imageView.contentMode = .scaleAspectFit
            return imageView
        }
        let button = UIButton(primaryAction: UIAction { [weak self] _ in
            self?.onToggleTask?(decoration.range)
        })
        button.setImage(image, for: .normal)
        button.tintColor = decoration.tintColor
        button.accessibilityLabel = decoration.accessibilityLabel
        return button
    }
}
#endif
