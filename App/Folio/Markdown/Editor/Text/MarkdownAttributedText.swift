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

    /// Images already on the device load right away; the rest download through file coordination in `loads`
    /// and call `onImageLoaded` when they arrive.
    static func attributedString(
        fromMarkdown markdown: String,
        baseURL: URL?,
        loads: inout [Task<Void, Never>],
        onImageLoaded: @escaping @MainActor (MarkdownImageAttachment) -> Void
    ) -> NSAttributedString {
        let result = NSMutableAttributedString(string: markdown)
        let source = markdown as NSString
        for reference in MarkdownImageReference.references(in: markdown).reversed() {
            guard let url = MarkdownURLResolver.url(for: reference.source, relativeTo: baseURL),
                  MarkdownImageLoader.exists(url) else {
                continue
            }
            let markdown = source.substring(with: reference.range)
            let image = MarkdownImageLoader.isOnDevice(url) ? MarkdownImageLoader.thumbnail(at: url) : nil
            let attachment = MarkdownImageAttachment(markdown: markdown, image: image)
            if image == nil {
                loads.append(load(url, into: attachment, onImageLoaded: onImageLoaded))
            }
            result.replaceCharacters(in: reference.range, with: NSAttributedString(attachment: attachment))
        }
        return result
    }

    private static func load(
        _ url: URL,
        into attachment: MarkdownImageAttachment,
        onImageLoaded: @escaping @MainActor (MarkdownImageAttachment) -> Void
    ) -> Task<Void, Never> {
        Task { @MainActor in
            guard let data = try? await NoteFileStore.coordinatedData(at: url),
                  let image = await MarkdownImageLoader.thumbnail(from: data),
                  !Task.isCancelled else {
                return
            }
            attachment.image = MarkdownImageLoader.platformImage(from: image)
            onImageLoaded(attachment)
        }
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
