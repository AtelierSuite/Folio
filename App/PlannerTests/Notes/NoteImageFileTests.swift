import CoreGraphics
import Foundation
import ImageIO
import Testing
import UniformTypeIdentifiers
@testable import Planner

struct NoteImageFileTests {
    private func encodedImage(as type: UTType) throws -> Data {
        let context = try #require(CGContext(
            data: nil, width: 4, height: 4, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ))
        context.setFillColor(red: 1, green: 0, blue: 0, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: 4, height: 4))
        let image = try #require(context.makeImage())
        let output = NSMutableData()
        let destination = try #require(CGImageDestinationCreateWithData(output, type.identifier as CFString, 1, nil))
        CGImageDestinationAddImage(destination, image, nil)
        #expect(CGImageDestinationFinalize(destination))
        return output as Data
    }

    @Test func keepsPortableFormats() async throws {
        let png = try encodedImage(as: .png)
        let file = await NoteImageFile.prepared(from: png, type: .png)
        #expect(file == NoteImageFile(data: png, fileExtension: "png"))
    }

    @Test func reencodesOtherFormatsAsJPEG() async throws {
        let tiff = try encodedImage(as: .tiff)
        let file = try #require(await NoteImageFile.prepared(from: tiff, type: .tiff))
        #expect(file.fileExtension == "jpg")
        let source = try #require(CGImageSourceCreateWithData(file.data as CFData, nil))
        #expect(CGImageSourceGetType(source) as String? == UTType.jpeg.identifier)
    }

    @Test func rejectsDataThatIsNotAnImage() async {
        #expect(await NoteImageFile.prepared(from: Data("text".utf8), type: nil) == nil)
    }
}
