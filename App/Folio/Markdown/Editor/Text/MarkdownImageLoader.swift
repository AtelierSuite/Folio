import Foundation
import ImageIO
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif
import Planner

enum MarkdownImageLoader {
    private static let scale: CGFloat = 2

    struct DecodedImage {
        let image: PlatformImage
        let isFullSize: Bool
    }

    private struct Thumbnail: @unchecked Sendable {
        let image: CGImage
        let isFullSize: Bool
    }

    static func image(at url: URL, pixelWidth: Int) async -> DecodedImage? {
        guard let data = try? await NoteFileStore.coordinatedData(at: url),
              let thumbnail = await thumbnail(from: data, pixelWidth: pixelWidth) else {
            return nil
        }
        return DecodedImage(image: platformImage(from: thumbnail.image), isFullSize: thumbnail.isFullSize)
    }

    /// An evicted iCloud image still counts, since a coordinated read can download it.
    static func exists(_ url: URL) -> Bool {
        url.isFileURL && (FileManager.default.fileExists(atPath: url.path(percentEncoded: false))
            || FileManager.default.isUbiquitousItem(at: url))
    }

    @concurrent
    private static func thumbnail(from data: Data, pixelWidth: Int) async -> Thumbnail? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] ?? [:]
        let imageWidth = (properties[kCGImagePropertyPixelWidth] as? NSNumber)?.intValue ?? 0
        let imageHeight = (properties[kCGImagePropertyPixelHeight] as? NSNumber)?.intValue ?? 0
        let isRotated = ((properties[kCGImagePropertyOrientation] as? NSNumber)?.intValue ?? 1) >= 5
        let size = MarkdownThumbnailSize(imageWidth: imageWidth, imageHeight: imageHeight, isRotated: isRotated)
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: size.maxPixelSize(fittingWidth: pixelWidth),
            kCGImageSourceShouldCacheImmediately: true
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }
        return Thumbnail(image: image, isFullSize: size.isFullSize(fittingWidth: pixelWidth))
    }

    private static func platformImage(from image: CGImage) -> PlatformImage {
        #if canImport(UIKit)
        return UIImage(cgImage: image, scale: scale, orientation: .up)
        #else
        let size = NSSize(width: CGFloat(image.width) / scale, height: CGFloat(image.height) / scale)
        return NSImage(cgImage: image, size: size)
        #endif
    }
}
