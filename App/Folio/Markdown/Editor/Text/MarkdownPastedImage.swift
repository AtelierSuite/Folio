import Foundation
import UniformTypeIdentifiers

struct MarkdownPastedImage: Equatable {
    let id = UUID()
    let data: Data
    let type: UTType?
    let name: String?

    static let preferredTypes: [UTType] = [.png, .jpeg, .gif, .heic, .tiff]
}
