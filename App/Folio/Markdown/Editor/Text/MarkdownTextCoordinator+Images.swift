import Foundation
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

extension MarkdownTextCoordinator {
    /// Images already decoded in the editor are carried over, so reloading a note doesn't decode them again.
    func attributedString(fromMarkdown markdown: String) -> NSAttributedString {
        var images: [URL: MarkdownImageAttachment] = [:]
        for attachment in imageAttachments() where attachment.image != nil {
            images[attachment.url] = attachment
        }
        return MarkdownAttributedText.attributedString(fromMarkdown: markdown, baseURL: baseURL, reusing: images)
    }

    func loadImages() {
        for attachment in imageAttachments()
        where attachment.image == nil && imageLoads[ObjectIdentifier(attachment)] == nil {
            loadImage(into: attachment)
        }
    }

    func cancelImageLoads() {
        imageLoads.values.forEach { $0.cancel() }
        imageLoads.removeAll()
    }

    private func imageAttachments() -> [MarkdownImageAttachment] {
        guard let host else { return [] }
        let storage = host.markdownStorage
        return MarkdownAttributedText.attachments(in: storage, range: NSRange(location: 0, length: storage.length))
            .compactMap { $0.1 as? MarkdownImageAttachment }
    }

    private func loadImage(into attachment: MarkdownImageAttachment) {
        let key = ObjectIdentifier(attachment)
        let url = attachment.url
        imageLoads[key] = Task { [weak self] in
            let image = await MarkdownImageLoader.image(at: url)
            guard !Task.isCancelled, let self else { return }
            imageLoads[key] = nil
            guard let image else { return }
            attachment.image = image
            imageDidLoad(attachment)
        }
    }

    /// Lays the image out at its real size and moves the bullets and checkboxes below it along.
    private func imageDidLoad(_ attachment: MarkdownImageAttachment) {
        guard let host else { return }
        let storage = host.markdownStorage
        let fullRange = NSRange(location: 0, length: storage.length)
        guard let location = MarkdownAttributedText.attachments(in: storage, range: fullRange)
            .first(where: { $0.1 === attachment })?.0 else {
            return
        }
        storage.beginEditing()
        storage.edited(.editedAttributes, range: NSRange(location: location, length: 1), changeInLength: 0)
        storage.endEditing()
        restyle()
    }
}
