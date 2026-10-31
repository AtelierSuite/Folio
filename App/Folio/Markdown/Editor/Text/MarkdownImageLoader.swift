import Foundation
import ImageIO
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

enum MarkdownImageLoader {
    private static let scale: CGFloat = 2

    static func thumbnail(at url: URL, maxPixelSize: Int = 2048) -> PlatformImage? {
        guard url.isFileURL, let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
            kCGImageSourceShouldCacheImmediately: true
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }
        #if canImport(UIKit)
        return UIImage(cgImage: image, scale: scale, orientation: .up)
        #else
        let size = NSSize(width: CGFloat(image.width) / scale, height: CGFloat(image.height) / scale)
        return NSImage(cgImage: image, size: size)
        #endif
    }
}
