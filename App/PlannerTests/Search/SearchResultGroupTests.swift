import Foundation
import Testing
@testable import Planner

struct SearchResultGroupTests {
    @Test func groupsByDayWithUndatedItemsLast() {
        let documents = [
            SearchDocument(reminder: SearchFixtures.reminder("Someday")),
            SearchDocument(event: SearchFixtures.event("Late", start: Fixtures.date(2026, 10, 29, hour: 17))),
            SearchDocument(event: SearchFixtures.event("Next day", start: Fixtures.date(2026, 10, 30, hour: 9))),
            SearchDocument(event: SearchFixtures.event("Early", start: Fixtures.date(2026, 10, 29, hour: 8)))
        ]
        let groups = SearchResultGroup.grouped(documents, calendar: Fixtures.calendar)
        #expect(groups.map(\.day) == [Fixtures.date(2026, 10, 29), Fixtures.date(2026, 10, 30), nil])
        #expect(groups.first?.documents.map(\.title) == ["Early", "Late"])
    }

    @Test func completedRemindersWithoutDueDateUseTheirCompletionDate() {
        let completed = Fixtures.date(2026, 10, 2, hour: 10)
        let document = SearchDocument(reminder: SearchFixtures.reminder(
            "Renew passport", isCompleted: true, completionDate: completed
        ))
        #expect(document.date == completed)
        #expect(document.destination == .calendarDay(completed, item: document.reminderReference))
    }

    @Test func notesUseTheirFrontMatterDate() {
        let note = SearchFixtures.note("Log", text: "---\ndate: 2026-03-04\n---\nBody")
        #expect(Calendar.current.dateComponents([.year, .month, .day], from: note.date ?? .distantPast)
            == DateComponents(year: 2026, month: 3, day: 4))
        #expect(note.body.hasPrefix("Body"))
        #expect(note.snippet(matching: "") == "Body date: 2026-03-04")
    }

    @Test func snippetShowsTextAroundTheMatch() {
        let filler = String(repeating: "lorem ", count: 40)
        let note = SearchFixtures.note("Long", text: "\(filler)the Ferry leaves at noon\n\(filler)")
        let snippet = note.snippet(matching: "ferry", length: 40)
        #expect(snippet?.contains("Ferry leaves") == true)
        #expect(snippet?.hasPrefix("…") == true)
        #expect(SearchFixtures.note("Empty", text: "").snippet(matching: "x") == nil)
    }
}

private extension SearchDocument {
    var reminderReference: CalendarItemReference? {
        guard case .calendarDay(_, let item) = destination else { return nil }
        return item
    }
}
