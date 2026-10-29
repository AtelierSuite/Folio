import Foundation
import UniformTypeIdentifiers

/// A file Siri hands to a note intent, saved to the notes' assets folder and linked from the note.
public struct NoteAttachment: Sendable, Equatable {
    public let data: Data
    public let fileName: String
    public let isImage: Bool

    public init(data: Data, fileName: String, type: UTType?) {
        self.data = data
        self.fileName = fileName
        self.isImage = type?.conforms(to: .image) ?? false
    }

    func markdownLink(to path: String) -> String {
        let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? path
        return isImage ? "![\(fileName)](\(encodedPath))" : "[\(fileName)](\(encodedPath))"
    }
}
