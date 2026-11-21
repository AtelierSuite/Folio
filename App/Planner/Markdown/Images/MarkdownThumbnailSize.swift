import CoreGraphics

public struct MarkdownThumbnailSize: Sendable {
    private static let widthStep: CGFloat = 256

    let imageWidth: Int
    let imageHeight: Int
    let isRotated: Bool

    public init(imageWidth: Int, imageHeight: Int, isRotated: Bool) {
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.isRotated = isRotated
    }

    /// Rounded up in steps, so resizing a window only decodes images again once the editor has grown noticeably.
    public static func pixelWidth(forPointWidth pointWidth: CGFloat, scale: CGFloat) -> Int {
        guard pointWidth > 0, scale > 0 else { return 0 }
        return Int((pointWidth * scale / widthStep).rounded(.up) * widthStep)
    }

    private var uprightWidth: Int {
        isRotated ? imageHeight : imageWidth
    }

    /// The longest side to decode for the upright image to be `pixelWidth` wide, never more than the original.
    public func maxPixelSize(fittingWidth pixelWidth: Int) -> Int {
        let longestSide = max(imageWidth, imageHeight)
        guard uprightWidth > 0, pixelWidth > 0, !isFullSize(fittingWidth: pixelWidth) else {
            return longestSide > 0 ? longestSide : pixelWidth
        }
        return Int((Double(longestSide) * Double(pixelWidth) / Double(uprightWidth)).rounded(.up))
    }

    public func isFullSize(fittingWidth pixelWidth: Int) -> Bool {
        pixelWidth >= uprightWidth
    }
}
