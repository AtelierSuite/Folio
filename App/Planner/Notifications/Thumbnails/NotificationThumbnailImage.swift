import Foundation
import ImageIO
import UniformTypeIdentifiers

/// A small copy of a note's image, so a large photo doesn't get copied for every alert.
enum NotificationThumbnailImage {
    static let maximumPixelSize = 600

    static func jpegData(from url: URL) -> Data? {
        try? FileCoordination.read(at: url) { coordinatedURL in
            guard let source = CGImageSourceCreateWithURL(coordinatedURL as CFURL, nil) else { return nil }
            let options: [CFString: Any] = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: maximumPixelSize
            ]
            guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
                return nil
            }
            let output = NSMutableData()
            guard let destination = CGImageDestinationCreateWithData(
                output, UTType.jpeg.identifier as CFString, 1, nil
            ) else {
                return nil
            }
            let quality = [kCGImageDestinationLossyCompressionQuality: 0.85] as CFDictionary
            CGImageDestinationAddImage(destination, image, quality)
            return CGImageDestinationFinalize(destination) ? output as Data : nil
        }
    }
}
