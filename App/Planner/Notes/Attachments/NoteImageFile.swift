import Foundation
import ImageIO
import UniformTypeIdentifiers

/// An image ready to save into the notes' assets folder, in a format other Markdown apps can show.
public struct NoteImageFile: Sendable, Equatable {
    public let data: Data
    public let fileExtension: String

    private static let portableTypes: [UTType] = [.png, .jpeg, .gif]

    public init(data: Data, fileExtension: String) {
        self.data = data
        self.fileExtension = fileExtension
    }

    /// Keeps PNG, JPEG and GIF as they are and re-encodes anything else, such as HEIC, as JPEG.
    @concurrent
    public static func prepared(from data: Data, type: UTType?) async -> NoteImageFile? {
        if let type, let portable = portableTypes.first(where: { type.conforms(to: $0) }),
           let fileExtension = portable.preferredFilenameExtension {
            return NoteImageFile(data: data, fileExtension: fileExtension)
        }
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            return nil
        }
        let output = NSMutableData()
        let jpeg = UTType.jpeg.identifier as CFString
        guard let destination = CGImageDestinationCreateWithData(output, jpeg, 1, nil) else {
            return nil
        }
        let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] ?? [:]
        var options: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: 0.85]
        options[kCGImagePropertyOrientation] = properties[kCGImagePropertyOrientation]
        CGImageDestinationAddImage(destination, image, options as CFDictionary)
        guard CGImageDestinationFinalize(destination) else {
            return nil
        }
        return NoteImageFile(data: output as Data, fileExtension: "jpg")
    }
}
