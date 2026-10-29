import Foundation
import Testing
@testable import Planner

struct LinkedNoteTemplateTests {
    private let utc = Fixtures.calendar.timeZone

    @Test func eventNoteLinksTheEventAndItsDay() {
        let occurrence = Fixtures.date(2026, 10, 29, hour: 9)
        let event = CalendarEvent(
            reference: Fixtures.reference(occurrence: occurrence),
            calendarIdentifier: "calendar-1",
            title: "Standup",
            startDate: occurrence,
            endDate: occurrence.addingTimeInterval(900)
        )
        let template = LinkedNoteTemplate.eventNote(for: event, timeZone: utc)
        let file = MarkdownNoteFile(contents: template.text)
        #expect(template.title == "Standup 2026-10-29")
        #expect(file.frontMatter.event == event.reference.storageKey)
        #expect(file.frontMatter.value(forKey: "date") == "2026-10-29")
        #expect(file.body == "# Standup\n")
    }

    @Test func dailyNoteIsDatedWithoutAnEvent() {
        let template = LinkedNoteTemplate.dailyNote(on: Fixtures.date(2026, 10, 29, hour: 23), timeZone: utc)
        let file = MarkdownNoteFile(contents: template.text)
        #expect(template.title == "2026-10-29")
        #expect(file.frontMatter.event == nil)
        #expect(file.frontMatter.value(forKey: "date") == "2026-10-29")
    }

    @Test func dailyNotesLiveInTheDailyFolder() {
        let date = Fixtures.date(2026, 1, 5)
        #expect(DailyNoteNaming.relativePath(for: date, timeZone: utc) == "Daily/2026-01-05.md")
        #expect(DailyNoteNaming.dayKey(ofRelativePath: "Daily/2026-01-05.markdown") == "2026-01-05")
        #expect(DailyNoteNaming.dayKey(ofRelativePath: "Daily/Ideas.md") == nil)
        #expect(DailyNoteNaming.dayKey(ofRelativePath: "Archive/Daily/2026-01-05.md") == nil)
    }

    @Test func storageKeysRoundTripIntoReferences() throws {
        let occurrence = Date(timeIntervalSince1970: 1_793_264_400)
        let recurring = try #require(CalendarItemReference(storageKey: "abc@google.com@1793264400"))
        #expect(recurring.externalIdentifier == "abc@google.com")
        #expect(recurring.occurrenceDate == occurrence)
        let single = try #require(CalendarItemReference(storageKey: "abc@google.com"))
        #expect(single.externalIdentifier == "abc@google.com")
        #expect(single.occurrenceDate == nil)
        let local = try #require(CalendarItemReference(storageKey: "local:XYZ"))
        #expect(local.externalIdentifier == nil)
        #expect(local.localIdentifier == "XYZ")
    }

    @Test func createsTheDailyNoteOnceAtItsPath() async throws {
        let directory = try TemporaryDirectory()
        let store = NoteFileStore(rootURL: directory.url)
        let first = try await store.createNoteIfMissing(atRelativePath: "Daily/2026-10-29.md", text: "first")
        let second = try await store.createNoteIfMissing(atRelativePath: "Daily/2026-10-29.md", text: "second")
        #expect(first.url == second.url)
        #expect(second.text == "first")
        #expect(try await store.notes().map(\.relativePath) == ["Daily/2026-10-29.md"])
    }
}
