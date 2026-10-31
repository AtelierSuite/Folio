import Foundation
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

/// Shows a note's image inline, and turns back into the Markdown it came from when the note is saved.
nonisolated final class MarkdownImageAttachment: NSTextAttachment {
    let markdown: String

    init(markdown: String, image: PlatformImage) {
        self.markdown = markdown
        super.init(data: nil, ofType: nil)
        self.image = image
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
        guard let size = image?.size, size.width > 0, size.height > 0 else { return .zero }
        let padding = (textContainer?.lineFragmentPadding ?? 0) * 2
        let containerWidth = (textContainer?.size.width ?? lineFragment.width) - padding
        let availableWidth = containerWidth > 0 ? containerWidth : size.width
        let width = min(size.width, availableWidth)
        return CGRect(x: 0, y: 0, width: width, height: size.height * width / size.width)
    }
}
