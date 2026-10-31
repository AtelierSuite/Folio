import Foundation
import Testing
@testable import Planner

struct LinkedNoteIndexTests {
    private let utc = Fixtures.calendar.timeZone

    private func note(
        _ relativePath: String,
        event: String? = nil,
        day: String? = nil,
        modified: TimeInterval = 0
    ) -> LinkedNote {
        let file = NoteFile(
            url: URL(filePath: "/notes/\(relativePath)"),
            relativePath: relativePath,
            modifiedDate: Date(timeIntervalSince1970: modified)
        )
        return LinkedNote(file: file, eventKey: event, dayKey: day)
    }

    @Test func findsTheNoteLinkedToAnEventByItsStorageKey() {
        let reference = Fixtures.reference()
        let index = LinkedNoteIndex(notes: [
            note("Other.md", event: "external-2"),
            note("Standup.md", event: reference.storageKey)
        ])
        #expect(index.note(linkedTo: reference)?.title == "Standup")
        #expect(index.note(linkedTo: Fixtures.reference(external: "external-3", local: "local-3")) == nil)
    }

    @Test func matchesAnOccurrenceOnlyOnItsOwnDate() {
        let occurrence = Fixtures.date(2026, 10, 29, hour: 9)
        let reference = Fixtures.reference(occurrence: occurrence)
        let nextReference = Fixtures.reference(occurrence: Fixtures.date(2026, 10, 30, hour: 9))
        let index = LinkedNoteIndex(notes: [note("Standup.md", event: reference.storageKey)])
        #expect(index.note(linkedTo: reference) != nil)
        #expect(index.note(linkedTo: nextReference) == nil)
    }

    @Test func fallsBackToTheLocalIdentifierWhenTheEventGainsAnExternalOne() {
        let linkedBeforeSync = Fixtures.reference(external: nil, local: "local-1")
        let index = LinkedNoteIndex(notes: [note("Standup.md", event: linkedBeforeSync.storageKey)])
        #expect(linkedBeforeSync.storageKey == "local:local-1")
        #expect(index.note(linkedTo: Fixtures.reference(external: "synced-1", local: "local-1"))?.title == "Standup")
    }

    @Test func prefersTheNewestOfSeveralLinkedNotes() {
        let reference = Fixtures.reference()
        let index = LinkedNoteIndex(notes: [
            note("Old.md", event: reference.storageKey, modified: 10),
            note("New.md", event: reference.storageKey, modified: 20)
        ])
        #expect(index.note(linkedTo: reference)?.title == "New")
    }

    @Test func findsTheDailyNoteByItsPathOnly() {
        let day = Fixtures.date(2026, 10, 29, hour: 15)
        let index = LinkedNoteIndex(notes: [
            note("Journal.md", day: "2026-10-29", modified: 50),
            note("Daily/2026-10-29.md", modified: 10),
            note("Daily/2026-10-30.md")
        ])
        #expect(index.dailyNote(on: day, timeZone: utc)?.file.relativePath == "Daily/2026-10-29.md")
        #expect(index.dailyNote(on: Fixtures.date(2026, 10, 31), timeZone: utc) == nil)
    }

    @Test func parsesDayKeysBackIntoDates() {
        #expect(DailyNoteNaming.date(forDayKey: "2026-10-29", timeZone: utc) == Fixtures.date(2026, 10, 29))
        #expect(DailyNoteNaming.date(forDayKey: "Ideas", timeZone: utc) == nil)
    }
}
