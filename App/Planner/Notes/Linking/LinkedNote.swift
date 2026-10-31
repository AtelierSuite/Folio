import Foundation

/// A note found for an event, through the note index, or for a day, through its `Daily/` path.
public struct LinkedNote: Identifiable, Hashable, Sendable {
    public static let previewLength = 280

    public let file: NoteFile
    public let eventKey: String?
    public let dayKey: String?

    public init(file: NoteFile, eventKey: String? = nil, dayKey: String? = nil) {
        self.file = file
        self.eventKey = eventKey
        self.dayKey = dayKey
    }

    public var id: URL { file.url }
    public var url: URL { file.url }
    public var title: String { file.title }
}
