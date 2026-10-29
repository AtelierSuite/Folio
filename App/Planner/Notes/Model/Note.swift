import Foundation

public struct Note: Identifiable, Hashable, Sendable {
    public let url: URL
    public let modifiedDate: Date
    public let text: String

    public init(url: URL, modifiedDate: Date, text: String) {
        self.url = url
        self.modifiedDate = modifiedDate
        self.text = text
    }

    public var id: URL { url }

    public var title: String { url.noteTitle }
}

extension URL {
    var noteTitle: String {
        deletingPathExtension().lastPathComponent
    }
}
