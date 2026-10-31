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
        return LinkedNoteTemplate(title: "\(displayTitle) \(dayKey)", text: "# \(displayTitle)\n")
    }

    public static func dailyNote(on date: Date, timeZone: TimeZone = .current) -> LinkedNoteTemplate {
        LinkedNoteTemplate(title: DailyNoteNaming.dayKey(for: date, timeZone: timeZone), text: "")
    }
}
