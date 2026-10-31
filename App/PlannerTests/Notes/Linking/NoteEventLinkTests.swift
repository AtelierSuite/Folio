import Foundation
import Testing
@testable import Planner

struct NoteEventLinkTests {
    private let utc = Fixtures.calendar.timeZone

    private func event() -> CalendarEvent {
        let occurrence = Fixtures.date(2026, 10, 29, hour: 9)
        return CalendarEvent(
            reference: Fixtures.reference(occurrence: occurrence),
            calendarIdentifier: "calendar-1",
            title: "Standup",
            startDate: occurrence,
            endDate: occurrence.addingTimeInterval(900)
        )
    }

    @Test func linksANoteWithoutFrontMatter() {
        let event = event()
        let linked = NoteEventLink.linking("# Notes\nbody", to: event, timeZone: utc)
        let file = MarkdownNoteFile(contents: linked)
        #expect(file.frontMatter.event == event.reference.storageKey)
        #expect(file.frontMatter.value(forKey: "date") == "2026-10-29")
        #expect(file.body == "# Notes\nbody")
        #expect(NoteEventLink.eventKey(in: linked) == event.reference.storageKey)
    }

    @Test func unlinkingKeepsOtherFrontMatter() {
        let linked = NoteEventLink.linking("---\ntags: [work]\n---\nbody", to: event(), timeZone: utc)
        let unlinked = NoteEventLink.unlinking(linked)
        let file = MarkdownNoteFile(contents: unlinked)
        #expect(file.frontMatter.event == nil)
        #expect(file.frontMatter.tags == ["work"])
        #expect(file.body == "body")
    }

    @Test func unlinkingDropsEmptyFrontMatter() {
        let text = "---\nevent: key\n---\nbody"
        #expect(NoteEventLink.unlinking(text) == "body")
    }

    @Test func sharesMarkdownWithoutFrontMatter() {
        #expect(MarkdownNoteFile.shareableMarkdown(from: "---\nevent: key\n---\n\n# Title") == "# Title")
        #expect(MarkdownNoteFile.shareableMarkdown(from: "plain") == "plain")
    }
}
