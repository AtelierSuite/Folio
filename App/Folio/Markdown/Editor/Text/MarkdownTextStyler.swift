import Foundation
import Planner
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

/// Restyles the whole text from its Markdown on every change. Only attributes change, never characters,
/// so the cursor and the Markdown source stay as they are. Markdown symbols are hidden, by shrinking them
/// to nothing, everywhere but the lines in `revealedRange`, so they only show where the user is editing.
enum MarkdownTextStyler {
    static var baseAttributes: [NSAttributedString.Key: Any] {
        [
            .font: MarkdownEditorStyle.bodyFont,
            .foregroundColor: MarkdownEditorStyle.textColor,
            .paragraphStyle: MarkdownEditorStyle.paragraphStyle
        ]
    }

    @discardableResult
    static func style(_ storage: NSTextStorage, revealing revealedRange: NSRange?) -> [MarkdownListDecoration] {
        let fullRange = NSRange(location: 0, length: storage.length)
        let attachments = MarkdownAttributedText.attachments(in: storage, range: fullRange)
        let highlights = MarkdownHighlighter.highlights(in: storage.string)
        let revealed = revealedRange.map { expanded($0, toBlocksIn: highlights, of: storage.string as NSString) }
        storage.beginEditing()
        storage.setAttributes(baseAttributes, range: fullRange)
        for highlight in highlights {
            apply(highlight, to: storage)
        }
        for highlight in highlights where isHidden(highlight, outside: revealed) {
            hide(highlight.range, in: storage)
        }
        let decorations = highlights.compactMap { decoration(for: $0, outside: revealed) }
        for decoration in decorations {
            conceal(decoration, in: storage)
        }
        for (location, attachment) in attachments {
            storage.addAttribute(.attachment, value: attachment, range: NSRange(location: location, length: 1))
        }
        storage.endEditing()
        return decorations
    }

    private static func apply(_ highlight: MarkdownHighlight, to storage: NSTextStorage) {
        if let transform = fontTransform(for: highlight.kind) {
            updateFonts(in: storage, range: highlight.range, transform)
        }
        if let attributes = attributes(for: highlight.kind) {
            storage.addAttributes(attributes, range: highlight.range)
        }
    }

    private static func fontTransform(for kind: MarkdownHighlight.Kind) -> ((PlatformFont) -> PlatformFont)? {
        switch kind {
        case .frontMatter: { _ in MarkdownEditorStyle.frontMatterFont }
        case .heading(let level): { _ in MarkdownEditorStyle.headingFont(level: level) }
        case .bold: { MarkdownEditorStyle.adding(.bold, to: $0) }
        case .italic: { MarkdownEditorStyle.adding(.italic, to: $0) }
        case .inlineCode, .codeBlock: MarkdownEditorStyle.monospaced(matching:)
        default: nil
        }
    }

    private static func attributes(for kind: MarkdownHighlight.Kind) -> [NSAttributedString.Key: Any]? {
        let strikethrough = NSUnderlineStyle.single.rawValue
        return switch kind {
        case .frontMatter, .syntax: [.foregroundColor: MarkdownEditorStyle.syntaxColor]
        case .strikethrough: [.strikethroughStyle: strikethrough]
        case .inlineCode, .codeBlock: [.backgroundColor: MarkdownEditorStyle.codeBackground]
        case .blockQuote:
            [
                .foregroundColor: MarkdownEditorStyle.secondaryColor,
                .paragraphStyle: MarkdownEditorStyle.quoteParagraphStyle
            ]
        case .listMarker: [.foregroundColor: MarkdownEditorStyle.secondaryColor]
        case .link: [.foregroundColor: MarkdownEditorStyle.linkColor]
        case .completedTask: [.foregroundColor: MarkdownEditorStyle.secondaryColor, .strikethroughStyle: strikethrough]
        case .horizontalRule: [.foregroundColor: MarkdownEditorStyle.syntaxColor]
        case .heading, .bold, .italic, .bullet, .task: nil
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
