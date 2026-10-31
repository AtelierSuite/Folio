import Foundation
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

extension MarkdownListDecoration {
    var symbolName: String {
        switch kind {
        case .bullet, .rule: "circle.fill"
        case .task(let isChecked): isChecked ? "checkmark.circle.fill" : "circle"
        }
    }

    var tintColor: PlatformColor {
        switch kind {
        case .bullet: MarkdownEditorStyle.secondaryColor
        case .rule: MarkdownEditorStyle.syntaxColor
        case .task(let isChecked): isChecked ? MarkdownEditorStyle.linkColor : MarkdownEditorStyle.syntaxColor
        }
    }

    var accessibilityLabel: String {
        switch kind {
        case .bullet, .rule: ""
        case .task(true): String(localized: "Task.Completed", table: "Markdown")
        case .task(false): String(localized: "Task.NotCompleted", table: "Markdown")
        }
    }

    /// The width the concealed marker is squeezed to, leaving a small gap after the checkbox.
    var concealedWidth: CGFloat? {
        guard case .task = kind else { return nil }
        return MarkdownEditorStyle.bodyFont.pointSize * 1.6
    }

    /// Sits at the start of the concealed marker, centred on its line.
    func frame(inLine lineFrame: CGRect, origin: CGPoint, lineWidth: CGFloat) -> CGRect {
        if kind == .rule {
            let padding = lineFrame.minX
            let width = lineWidth - padding * 2
            return CGRect(x: origin.x + padding, y: origin.y + lineFrame.midY, width: width, height: 1)
        }
        let bodySize = MarkdownEditorStyle.bodyFont.pointSize
        let side = kind == .bullet ? bodySize * 0.35 : bodySize * 1.2
        let lineHeight = min(lineFrame.height, MarkdownEditorStyle.bodyFont.lineHeight)
        let leading = kind == .bullet ? bodySize * 0.2 : 0
        return CGRect(
            x: origin.x + lineFrame.minX + leading,
            y: origin.y + lineFrame.minY + (lineHeight - side) / 2,
            width: side,
            height: side
        )
    }
}

#if os(macOS)
private extension NSFont {
    var lineHeight: CGFloat {
        ascender - descender + leading
    }
}
#endif
