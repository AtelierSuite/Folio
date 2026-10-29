import Foundation

public struct LinkedNoteTemplate: Sendable, Equatable {
    public let title: String
    public let text: String

    public static func eventNote(for event: CalendarEvent, timeZone: TimeZone = .current) -> LinkedNoteTemplate {
        let eventTitle = event.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayTitle = eventTitle.isEmpty
            ? String(localized: "EventNote.UntitledEvent", table: "LinkedNotes", bundle: #bundle)
            : eventTitle
        let dayKey = DailyNoteNaming.dayKey(for: event.startDate, timeZone: timeZone)
        var frontMatter = MarkdownFrontMatter()
        frontMatter.event = event.reference.storageKey
        frontMatter.setValue(dayKey, forKey: MarkdownFrontMatter.dateKey)
        let file = MarkdownNoteFile(frontMatter: frontMatter, body: "# \(displayTitle)\n")
        return LinkedNoteTemplate(title: "\(displayTitle) \(dayKey)", text: file.contents)
    }

    public static func dailyNote(on date: Date, timeZone: TimeZone = .current) -> LinkedNoteTemplate {
        let dayKey = DailyNoteNaming.dayKey(for: date, timeZone: timeZone)
        var frontMatter = MarkdownFrontMatter()
        frontMatter.setValue(dayKey, forKey: MarkdownFrontMatter.dateKey)
        return LinkedNoteTemplate(title: dayKey, text: MarkdownNoteFile(frontMatter: frontMatter, body: "").contents)
    }
}
