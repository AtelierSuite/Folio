import Foundation
import Planner
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

/// Restyles the whole text from its Markdown on every change. Only attributes change, never characters,
/// so the cursor and the Markdown source stay as they are.
enum MarkdownTextStyler {
    static var baseAttributes: [NSAttributedString.Key: Any] {
        [
            .font: MarkdownEditorStyle.bodyFont,
            .foregroundColor: MarkdownEditorStyle.textColor,
            .paragraphStyle: MarkdownEditorStyle.paragraphStyle
        ]
    }

    static func style(_ storage: NSTextStorage) {
        let fullRange = NSRange(location: 0, length: storage.length)
        let attachments = MarkdownAttributedText.attachments(in: storage, range: fullRange)
        storage.beginEditing()
        storage.setAttributes(baseAttributes, range: fullRange)
        for highlight in MarkdownHighlighter.highlights(in: storage.string) {
            apply(highlight, to: storage)
        }
        for (location, attachment) in attachments {
            storage.addAttribute(.attachment, value: attachment, range: NSRange(location: location, length: 1))
        }
        storage.endEditing()
    }

    private static func apply(_ highlight: MarkdownHighlight, to storage: NSTextStorage) {
        let range = highlight.range
        switch highlight.kind {
        case .frontMatter:
            storage.addAttributes(
                [.font: MarkdownEditorStyle.frontMatterFont, .foregroundColor: MarkdownEditorStyle.syntaxColor],
                range: range
            )
        case .heading(let level):
            storage.addAttribute(.font, value: MarkdownEditorStyle.headingFont(level: level), range: range)
        case .bold:
            updateFonts(in: storage, range: range) { MarkdownEditorStyle.adding(.bold, to: $0) }
        case .italic:
            updateFonts(in: storage, range: range) { MarkdownEditorStyle.adding(.italic, to: $0) }
        case .strikethrough:
            storage.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        case .inlineCode, .codeBlock:
            updateFonts(in: storage, range: range, MarkdownEditorStyle.monospaced(matching:))
            storage.addAttribute(.backgroundColor, value: MarkdownEditorStyle.codeBackground, range: range)
        case .blockQuote, .listMarker:
            storage.addAttribute(.foregroundColor, value: MarkdownEditorStyle.secondaryColor, range: range)
        case .link:
            storage.addAttribute(.foregroundColor, value: MarkdownEditorStyle.linkColor, range: range)
        case .completedTask:
            storage.addAttributes(
                [
                    .foregroundColor: MarkdownEditorStyle.secondaryColor,
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue
                ],
                range: range
            )
        case .syntax:
            storage.addAttribute(.foregroundColor, value: MarkdownEditorStyle.syntaxColor, range: range)
        }
    }

    private static func updateFonts(
        in storage: NSTextStorage,
        range: NSRange,
        _ transform: (PlatformFont) -> PlatformFont
    ) {
        storage.enumerateAttribute(.font, in: range) { value, fontRange, _ in
            let font = value as? PlatformFont ?? MarkdownEditorStyle.bodyFont
            storage.addAttribute(.font, value: transform(font), range: fontRange)
        }
    }
}
