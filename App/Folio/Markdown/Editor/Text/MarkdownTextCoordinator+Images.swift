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

    /// Waits until the editor has a width, and loads again at a higher resolution when it grows.
    func loadImages() {
        guard let pixelWidth = host?.markdownImagePixelWidth, pixelWidth > 0 else { return }
        for attachment in imageAttachments() where attachment.requestedPixelWidth < pixelWidth {
            loadImage(into: attachment, pixelWidth: pixelWidth)
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

    private func loadImage(into attachment: MarkdownImageAttachment, pixelWidth: Int) {
        let key = ObjectIdentifier(attachment)
        let url = attachment.url
        attachment.requestedPixelWidth = pixelWidth
        imageLoads[key]?.cancel()
        imageLoads[key] = Task { [weak self] in
            let decoded = await MarkdownImageLoader.image(at: url, pixelWidth: pixelWidth)
            guard !Task.isCancelled, let self else { return }
            imageLoads[key] = nil
            guard let decoded else { return }
            attachment.image = decoded.image
            if decoded.isFullSize {
                attachment.requestedPixelWidth = .max
            }
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
