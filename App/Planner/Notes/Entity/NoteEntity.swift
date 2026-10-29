import AppIntents
import Foundation

public struct NoteEntity: IndexedEntity, Identifiable, Sendable {
    public static let typeDisplayRepresentation = TypeDisplayRepresentation(
        name: LocalizedStringResource("NoteEntity.TypeName", table: "Spotlight", bundle: #bundle)
    )
    public static let defaultQuery = NoteEntityQuery()

    /// The note's path relative to the notes folder, so it stays valid across devices.
    public let id: String
    public let url: URL
    public let excerpt: String
    public let plainText: String

    @Property(title: LocalizedStringResource("NoteEntity.Title", table: "Spotlight", bundle: #bundle))
    public var title: String

    @Property(title: LocalizedStringResource("NoteEntity.Tags", table: "Spotlight", bundle: #bundle))
    public var tags: [String]

    @Property(title: LocalizedStringResource("NoteEntity.Date", table: "Spotlight", bundle: #bundle))
    public var date: Date?

    @Property(title: LocalizedStringResource("NoteEntity.ModifiedDate", table: "Spotlight", bundle: #bundle))
    public var modifiedDate: Date

    public init(
        id: String,
        url: URL,
        title: String,
        plainText: String = "",
        tags: [String] = [],
        date: Date? = nil,
        modifiedDate: Date
    ) {
        self.id = id
        self.url = url
        self.plainText = plainText
        self.excerpt = Self.excerpt(of: plainText)
        self.title = title
        self.tags = tags
        self.date = date
        self.modifiedDate = modifiedDate
    }

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: excerpt.isEmpty ? nil : "\(excerpt)",
            image: DisplayRepresentation.Image(systemName: "note.text")
        )
    }

    private static func excerpt(of plainText: String) -> String {
        let firstLines = plainText.split(whereSeparator: \.isNewline).prefix(3)
        return String(firstLines.joined(separator: " ").prefix(200))
    }
}
