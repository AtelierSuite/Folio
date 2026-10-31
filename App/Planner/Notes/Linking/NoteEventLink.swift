import Foundation

/// Tags an existing note to an event, or removes the tag, by editing the note's front matter.
public enum NoteEventLink {
    public static func eventKey(in text: String) -> String? {
        MarkdownNoteFile(contents: text).frontMatter.event
    }

    public static func linking(_ text: String, to event: CalendarEvent, timeZone: TimeZone = .current) -> String {
        var file = MarkdownNoteFile(contents: text)
        file.frontMatter.event = event.reference.storageKey
        file.frontMatter.setValue(
            DailyNoteNaming.dayKey(for: event.startDate, timeZone: timeZone),
            forKey: MarkdownFrontMatter.dateKey
        )
        return file.contents
    }

    public static func unlinking(_ text: String) -> String {
        var file = MarkdownNoteFile(contents: text)
        file.frontMatter.event = nil
        return file.contents
    }
}
