import Foundation
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

/// Shows a note's image inline, and turns back into the Markdown it came from when the note is saved. An image
/// still loading keeps a blank space the width of the text until it arrives.
nonisolated final class MarkdownImageAttachment: NSTextAttachment {
    let markdown: String
    let url: URL

    init(markdown: String, url: URL) {
        self.markdown = markdown
        self.url = url
        super.init(data: nil, ofType: nil)
    }

    func reuseImage(of other: MarkdownImageAttachment?) {
        guard let other, other.image != nil else { return }
        image = other.image
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
        guard let size = image?.size, size.width > 0, size.height > 0 else {
            let width = max(containerWidth, 0)
            return CGRect(x: 0, y: 0, width: width, height: width / 2)
        }
        let availableWidth = containerWidth > 0 ? containerWidth : size.width
        let width = min(size.width, availableWidth)
        return CGRect(x: 0, y: 0, width: width, height: size.height * width / size.width)
    }
}
