import Foundation
@testable import Planner

enum SearchFixtures {
    static func event(
        _ title: String,
        local: String? = nil,
        calendarIdentifier: String = "work",
        start: Date = Fixtures.date(2026, 10, 29, hour: 9),
        location: String? = nil,
        notes: String? = nil,
        url: URL? = nil
    ) -> CalendarEvent {
        let local = local ?? title
        return CalendarEvent(
            reference: Fixtures.reference(local: local, calendarIdentifier: calendarIdentifier, title: title),
            calendarIdentifier: calendarIdentifier,
            title: title,
            location: location,
            notes: notes,
            url: url,
            startDate: start,
            endDate: start.addingTimeInterval(3600)
        )
    }

    static func reminder(
        _ title: String,
        listIdentifier: String = "groceries",
        due: Date? = nil,
        isCompleted: Bool = false,
        completionDate: Date? = nil
    ) -> ReminderItem {
        ReminderItem(
            reference: Fixtures.reference(local: title, calendarIdentifier: listIdentifier, title: title),
            listIdentifier: listIdentifier,
            title: title,
            dueDate: due,
            isCompleted: isCompleted,
            completionDate: completionDate
        )
    }

    static func note(_ title: String, text: String, modified: Date = Fixtures.date(2026, 10, 1)) -> SearchDocument {
        let url = URL(filePath: "/notes/\(title).md")
        return SearchDocument(
            note: NoteFile(url: url, relativePath: "\(title).md", modifiedDate: modified),
            text: text
        )
    }

    static func index(_ documents: [SearchDocument]) -> SearchIndex {
        var index = SearchIndex()
        index.apply(upserting: documents, removing: [])
        return index
    }
}
