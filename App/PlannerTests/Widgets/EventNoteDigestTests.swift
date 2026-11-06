import Foundation
import Testing
@testable import Planner

struct EventNoteDigestTests {
    private let text = """
    # Widget review

    Decide which **two** ideas move forward.

    - [x] Share the contact sheet
    - [ ] Bring lock screen options
    * [X] Agree on the budget
    - An ordinary list item
    """

    private func digest(_ text: String) -> EventNoteDigest {
        EventNoteDigest(notePath: "Review.md", title: "Review", text: text)
    }

    @Test func readsChecklistItemsAndTheirState() {
        let checklist = digest(text).checklist
        let expected = ["Share the contact sheet", "Bring lock screen options", "Agree on the budget"]
        #expect(checklist.map(\.text) == expected)
        #expect(checklist.map(\.isDone) == [true, false, true])
    }

    @Test func listsOpenItems() {
        #expect(digest(text).openItems.map(\.text) == ["Bring lock screen options"])
    }

    @Test func summarisesTheFirstProseLineWithoutMarkdown() {
        #expect(digest(text).summary == "Decide which two ideas move forward.")
    }

    @Test func aNoteOfOnlyAHeadingHasNoSummary() {
        #expect(digest("# Title\n").summary.isEmpty)
    }

    @Test func capsTheChecklist() {
        let lines = (1...10).map { "- [ ] Item \($0)" }.joined(separator: "\n")
        #expect(digest(lines).checklist.count == EventNoteDigest.checklistLimit)
    }

    @Test func survivesTheStore() throws {
        let url = FileManager.default.temporaryDirectory.appending(path: "\(UUID().uuidString)/Digests.json")
        let store = EventNoteDigestStore(fileURL: url)
        store.store(["event": digest(text)])
        #expect(store.digests["event"] == digest(text))
        try FileManager.default.removeItem(at: url.deletingLastPathComponent())
    }

    @Test func findsTheNextEventWithANote() {
        let now = Fixtures.date(2026, 11, 6, hour: 10)
        let past = Fixtures.event(local: "past", start: Fixtures.date(2026, 11, 6, hour: 8))
        let plain = Fixtures.event(local: "plain", start: Fixtures.date(2026, 11, 6, hour: 11))
        let review = Fixtures.event(local: "review", start: Fixtures.date(2026, 11, 6, hour: 15))
        let snapshot = WidgetSnapshot(
            events: [past, plain, review],
            eventNotes: [past.reference.storageKey: digest(text), review.reference.storageKey: digest(text)]
        )
        let eventNote = snapshot.nextEventNote(at: now)
        #expect(eventNote?.event.title == "review")
        #expect(eventNote?.isOngoing == false)
    }

    @Test func leavesTheCurrentUserOutOfTheAttendees() {
        let attendees = [
            EventParticipant(name: "Mika", url: nil),
            EventParticipant(name: "Me", url: nil, isCurrentUser: true),
            EventParticipant(name: "Room", url: nil, type: .room)
        ]
        let event = CalendarEvent(
            reference: Fixtures.reference(),
            calendarIdentifier: "calendar-1",
            title: "Review",
            startDate: Fixtures.date(2026, 11, 6, hour: 15),
            endDate: Fixtures.date(2026, 11, 6, hour: 16),
            attendees: attendees
        )
        #expect(event.visibleAttendees.map(\.displayName) == ["Mika"])
    }
}
