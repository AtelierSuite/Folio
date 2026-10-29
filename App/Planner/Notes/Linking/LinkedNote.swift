import Foundation

/// What the index remembers about a note's links, read from its front matter.
public struct LinkedNote: Identifiable, Hashable, Sendable {
    public static let previewLength = 280

    public let file: NoteFile
    public let eventKey: String?
    public let dayKey: String?
    public let preview: String

    public init(file: NoteFile, eventKey: String? = nil, dayKey: String? = nil, preview: String = "") {
        self.file = file
        self.eventKey = eventKey
        self.dayKey = dayKey
        self.preview = preview
    }

    init(file: NoteFile, text: String?, timeZone: TimeZone = .current) {
        guard let text else {
            self.init(file: file)
            return
        }
        let document = MarkdownDocument(parsing: text)
        self.init(
            file: file,
            eventKey: document.frontMatter.event,
            dayKey: document.frontMatter.date.map { DailyNoteNaming.dayKey(for: $0, timeZone: timeZone) },
            preview: String(document.plainText.prefix(Self.previewLength))
        )
    }

    public var id: URL { file.url }
    public var url: URL { file.url }
    public var title: String { file.title }
}
