import Foundation
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif
import Planner

/// Converts between a note's Markdown and the editor's text, where each local image is one attachment character.
enum MarkdownAttributedText {
    private static let attachmentCharacter: unichar = 0xFFFC

    static func attributedString(fromMarkdown markdown: String, baseURL: URL?) -> NSAttributedString {
        let result = NSMutableAttributedString(string: markdown)
        let source = markdown as NSString
        for reference in MarkdownImageReference.references(in: markdown).reversed() {
            guard let url = MarkdownURLResolver.url(for: reference.source, relativeTo: baseURL),
                  let image = MarkdownImageLoader.thumbnail(at: url) else {
                continue
            }
            let attachment = MarkdownImageAttachment(markdown: source.substring(with: reference.range), image: image)
            result.replaceCharacters(in: reference.range, with: NSAttributedString(attachment: attachment))
        }
        return result
    }

    static func markdown(from text: NSAttributedString) -> String {
        let result = NSMutableString(string: text.string)
        let fullRange = NSRange(location: 0, length: text.length)
        for (location, attachment) in attachments(in: text, range: fullRange).reversed() {
            let markdown = (attachment as? MarkdownImageAttachment)?.markdown ?? ""
            result.replaceCharacters(in: NSRange(location: location, length: 1), with: markdown)
        }
        return result as String
    }

    /// Only attachment characters count, so text typed right after an image never carries its attachment along.
    static func attachments(in text: NSAttributedString, range: NSRange) -> [(Int, NSTextAttachment)] {
        let string = text.string as NSString
        var attachments: [(Int, NSTextAttachment)] = []
        text.enumerateAttribute(.attachment, in: range) { value, attributeRange, _ in
            guard let attachment = value as? NSTextAttachment else { return }
            for location in attributeRange.location..<NSMaxRange(attributeRange)
            where string.character(at: location) == attachmentCharacter {
                attachments.append((location, attachment))
            }
        }
        return attachments
    }

    static func isAttachmentCharacter(_ character: unichar) -> Bool {
        character == attachmentCharacter
    }
}
