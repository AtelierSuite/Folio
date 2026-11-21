import Foundation
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

/// Shows a note's image inline, and turns back into the Markdown it came from when the note is saved. An image
/// still loading shows a gray box the width of the text until it arrives.
nonisolated final class MarkdownImageAttachment: NSTextAttachment {
    let markdown: String
    let url: URL
    var requestedPixelWidth = 0
    private(set) var hasImage = false

    init(markdown: String, url: URL) {
        self.markdown = markdown
        self.url = url
        super.init(data: nil, ofType: nil)
        image = Self.placeholderImage()
    }

    func show(_ loadedImage: PlatformImage) {
        image = loadedImage
        hasImage = true
    }

    func reuseImage(of other: MarkdownImageAttachment?) {
        guard let other, other.hasImage, let otherImage = other.image else { return }
        show(otherImage)
        requestedPixelWidth = other.requestedPixelWidth
    }

    /// Text views draw a document icon for an attachment without an image, so a one-pixel fill is stretched instead.
    private static func placeholderImage() -> PlatformImage {
        let color = PlatformColor(white: 0.5, alpha: 0.15)
        #if canImport(UIKit)
        return UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { context in
            color.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        #else
        return NSImage(size: NSSize(width: 1, height: 1), flipped: false) { rect in
            color.setFill()
            rect.fill()
            return true
        }
        #endif
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func attachmentBounds(
        for attributes: [NSAttributedString.Key: Any],
        location: any NSTextLocation,
        textContainer: NSTextContainer?,
        proposedLineFragment: CGRect,
        position: CGPoint
    ) -> CGRect {
        fittedBounds(in: textContainer, lineFragment: proposedLineFragment)
    }

    override func attachmentBounds(
        for textContainer: NSTextContainer?,
        proposedLineFragment lineFragment: CGRect,
        glyphPosition position: CGPoint,
        characterIndex: Int
    ) -> CGRect {
        fittedBounds(in: textContainer, lineFragment: lineFragment)
    }

    private func fittedBounds(in textContainer: NSTextContainer?, lineFragment: CGRect) -> CGRect {
        let padding = (textContainer?.lineFragmentPadding ?? 0) * 2
        let containerWidth = (textContainer?.size.width ?? lineFragment.width) - padding
        guard hasImage, let size = image?.size, size.width > 0, size.height > 0 else {
            let width = max(containerWidth, 0)
            return CGRect(x: 0, y: 0, width: width, height: width / 2)
        }
        let availableWidth = containerWidth > 0 ? containerWidth : size.width
        let width = min(size.width, availableWidth)
        return CGRect(x: 0, y: 0, width: width, height: size.height * width / size.width)
    }
}
