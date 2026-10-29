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

    @Test func findsTheDailyNoteByPathBeforeFrontMatter() {
        let day = Fixtures.date(2026, 10, 29, hour: 15)
        let index = LinkedNoteIndex(notes: [
            note("Journal.md", day: "2026-10-29", modified: 50),
            note("Daily/2026-10-29.md", modified: 10)
        ])
        #expect(index.dailyNote(on: day, timeZone: utc)?.file.relativePath == "Daily/2026-10-29.md")
    }

    @Test func findsADatedNoteWithoutAnEventAsTheDailyNote() {
        let day = Fixtures.date(2026, 10, 29)
        let index = LinkedNoteIndex(notes: [
            note("Meeting.md", event: "external-1", day: "2026-10-29", modified: 50),
            note("Journal.md", day: "2026-10-29", modified: 10),
            note("Daily/2026-10-30.md")
        ])
        #expect(index.dailyNote(on: day, timeZone: utc)?.title == "Journal")
        #expect(index.dailyNote(on: Fixtures.date(2026, 10, 31), timeZone: utc) == nil)
    }

    @Test func readsLinksAndPreviewFromFrontMatter() {
        let file = NoteFile(url: URL(filePath: "/notes/A.md"), relativePath: "A.md", modifiedDate: .distantPast)
        let text = "---\nevent: \"external-1@1793264400\"\ndate: 2026-10-29\ntags: [work]\n---\n# Agenda\n\n- Budget\n"
        let linked = LinkedNote(file: file, text: text, timeZone: .current)
        #expect(linked.eventKey == "external-1@1793264400")
        #expect(linked.dayKey == "2026-10-29")
        #expect(linked.preview == "Agenda\nBudget")
    }

    @Test func rereadsOnlyNotesThatChanged() async throws {
        let directory = try TemporaryDirectory()
        try directory.write("---\nevent: first\n---\n", to: "A.md")
        try directory.write("---\ndate: 2026-10-29\n---\n", to: "B.md")
        let store = NoteFileStore(rootURL: directory.url)
        let index = await LinkedNoteIndex().updated(with: try await store.notes(), in: store)
        #expect(Set(index.notes.values.compactMap(\.eventKey)) == ["first"])

        let fileB = try #require(index.notes.values.first { $0.title == "B" }?.file)
        try directory.write("---\nevent: second\n---\n", to: "A.md")
        try directory.write("---\nevent: ignored\n---\n", to: "B.md")
        let changedA = try #require(try await store.notes().first { $0.title == "A" })
        let updated = await index.updated(
            with: [NoteFile(url: changedA.url, relativePath: "A.md", modifiedDate: .now), fileB], in: store
        )

        #expect(Set(updated.notes.values.compactMap(\.eventKey)) == ["second"])
        #expect(updated.notes.values.first { $0.title == "B" }?.dayKey == "2026-10-29")
    }

    @Test func dropsNotesThatAreGone() async throws {
        let directory = try TemporaryDirectory()
        try directory.write("---\nevent: first\n---\n", to: "A.md")
        let store = NoteFileStore(rootURL: directory.url)
        let index = await LinkedNoteIndex().updated(with: try await store.notes(), in: store)
        let emptied = await index.updated(with: [], in: store)
        #expect(index.notes.count == 1)
        #expect(emptied.notes.isEmpty)
    }
}
