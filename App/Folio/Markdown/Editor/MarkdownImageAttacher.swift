import Foundation
import Planner
import UniformTypeIdentifiers

/// Saves a picked image next to the note and returns the Markdown that shows it.
struct MarkdownImageAttacher {
    let saveAsset: (Data, String) async throws -> String

    func markdown(for data: Data, type: UTType?, named name: String?) async throws -> String {
        guard let file = await NoteImageFile.prepared(from: data, type: type) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        let baseName = name.map { ($0 as NSString).deletingPathExtension } ?? Self.timestampedName()
        let path = try await saveAsset(file.data, "\(baseName).\(file.fileExtension)")
        let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? path
        let altText = name.map { ($0 as NSString).deletingPathExtension }
            ?? String(localized: "Image.AltText", table: "Markdown")
        return "![\(altText)](\(encodedPath))"
    }

    private static func timestampedName() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return "image-\(formatter.string(from: .now))"
    }
}
