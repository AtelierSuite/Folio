import Foundation
import ImageIO
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

enum MarkdownImageLoader {
    private static let scale: CGFloat = 2

    static func thumbnail(at url: URL) -> PlatformImage? {
        guard url.isFileURL, let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let image = thumbnail(from: source) else {
            return nil
        }
        return platformImage(from: image)
    }

    @concurrent
    static func thumbnail(from data: Data) async -> CGImage? {
        CGImageSourceCreateWithData(data as CFData, nil).flatMap { thumbnail(from: $0) }
    }

    /// An evicted iCloud image still counts, since a coordinated read can download it.
    static func exists(_ url: URL) -> Bool {
        url.isFileURL && (FileManager.default.fileExists(atPath: url.path(percentEncoded: false))
            || FileManager.default.isUbiquitousItem(at: url))
    }

    static func isOnDevice(_ url: URL) -> Bool {
        guard FileManager.default.isUbiquitousItem(at: url) else { return true }
        var freshURL = url
        freshURL.removeAllCachedResourceValues()
        let status = try? freshURL.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
            .ubiquitousItemDownloadingStatus
        return status == .current
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

    static func platformImage(from image: CGImage) -> PlatformImage {
        #if canImport(UIKit)
        return UIImage(cgImage: image, scale: scale, orientation: .up)
        #else
        let size = NSSize(width: CGFloat(image.width) / scale, height: CGFloat(image.height) / scale)
        return NSImage(cgImage: image, size: size)
        #endif
    }
}
