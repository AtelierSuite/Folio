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

    static func image(at url: URL) async -> PlatformImage? {
        guard let data = try? await NoteFileStore.coordinatedData(at: url),
              let image = await thumbnail(from: data) else {
            return nil
        }
        return platformImage(from: image)
    }

    @concurrent
    private static func thumbnail(from data: Data) async -> CGImage? {
        CGImageSourceCreateWithData(data as CFData, nil).flatMap { thumbnail(from: $0) }
    }

    /// An evicted iCloud image still counts, since a coordinated read can download it.
    static func exists(_ url: URL) -> Bool {
        url.isFileURL && (FileManager.default.fileExists(atPath: url.path(percentEncoded: false))
            || FileManager.default.isUbiquitousItem(at: url))
    }

    private nonisolated static func thumbnail(from source: CGImageSource, maxPixelSize: Int = 2048) -> CGImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
            kCGImageSourceShouldCacheImmediately: true
        ]
        return CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
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
