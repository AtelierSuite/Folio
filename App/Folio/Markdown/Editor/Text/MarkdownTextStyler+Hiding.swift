import Foundation
import Planner
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

extension MarkdownTextStyler {
    /// The lines under the selection, grown to whole code blocks and front matter so their fences show together.
    static func expanded(
        _ selection: NSRange,
        toBlocksIn highlights: [MarkdownHighlight],
        of string: NSString
    ) -> NSRange {
        var revealed = string.paragraphRange(for: MarkdownTextCoordinator.clamped(selection, to: string.length))
        for highlight in highlights where highlight.kind == .codeBlock || highlight.kind == .frontMatter {
            if NSIntersectionRange(highlight.range, revealed).length > 0 || touches(highlight.range, revealed) {
                revealed = NSUnionRange(revealed, string.paragraphRange(for: highlight.range))
            }
        }
        return revealed
    }

    static func isHidden(_ highlight: MarkdownHighlight, outside revealed: NSRange?) -> Bool {
        guard highlight.kind == .syntax || highlight.kind == .frontMatter else { return false }
        guard let revealed else { return true }
        return NSIntersectionRange(highlight.range, revealed).length == 0 && !touches(highlight.range, revealed)
    }

    static func decoration(for highlight: MarkdownHighlight, outside revealed: NSRange?) -> MarkdownListDecoration? {
        let kind: MarkdownListDecoration.Kind
        switch highlight.kind {
        case .bullet: kind = .bullet
        case .task(let isChecked): kind = .task(isChecked: isChecked)
        case .horizontalRule: kind = .rule
        default: return nil
        }
        if let revealed,
           NSIntersectionRange(highlight.range, revealed).length > 0 || touches(highlight.range, revealed) {
            return nil
        }
        return MarkdownListDecoration(kind: kind, range: highlight.range)
    }

    /// Keeps the marker's characters but makes them invisible, and squeezes a task marker to the width of its
    /// checkbox so the task's text sits right next to it.
    static func conceal(_ decoration: MarkdownListDecoration, in storage: NSTextStorage) {
        storage.addAttribute(.foregroundColor, value: PlatformColor.clear, range: decoration.range)
        guard let targetWidth = decoration.concealedWidth, decoration.range.length > 0 else { return }
        let width = storage.attributedSubstring(from: decoration.range).size().width
        let kern = (targetWidth - width) / CGFloat(decoration.range.length)
        storage.addAttribute(.kern, value: kern, range: decoration.range)
    }

    static func hide(_ range: NSRange, in storage: NSTextStorage) {
        storage.addAttributes(
            [.font: MarkdownEditorStyle.hiddenFont, .foregroundColor: PlatformColor.clear],
            range: range
        )
        let string = storage.string as NSString
        let lines = string.paragraphRange(for: range)
        let content = string.substring(with: lines).trimmingCharacters(in: .newlines)
        if content == string.substring(with: range).trimmingCharacters(in: .newlines) {
            storage.addAttributes(
                [.font: MarkdownEditorStyle.hiddenFont, .paragraphStyle: MarkdownEditorStyle.hiddenParagraphStyle],
                range: lines
            )
        }
    }

    /// A caret right at either end of a range counts, so an empty selection next to a marker reveals it.
    private static func touches(_ range: NSRange, _ revealed: NSRange) -> Bool {
        revealed.length == 0 && revealed.location >= range.location && revealed.location <= NSMaxRange(range)
    }
}
