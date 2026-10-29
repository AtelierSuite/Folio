import Foundation
import Testing
@testable import Planner

struct EntityTransferTests {
    @Test func eventsShareTheirDetailsAsText() {
        let event = IntentTestSupport.event(
            "Dentist", start: Fixtures.date(2026, 11, 2, hour: 15), location: "Clinic", notes: "Bring forms"
        )

        let lines = EventEntity(event).plainTextSummary.split(separator: "\n").map(String.init)

        #expect(lines.first == "Dentist")
        #expect(lines.contains("Clinic"))
        #expect(lines.last == "Bring forms")
    }

    @Test func remindersAndNotesShareTheirText() {
        let reminder = Fixtures.reminder(local: "Pay rent", due: nil)
        let note = NoteEntity(
            id: "Plan.md", url: URL(filePath: "/tmp/Plan.md"), title: "Plan", plainText: "Ship it", modifiedDate: .now
        )

        #expect(ReminderEntity(reminder).plainTextSummary == "Pay rent")
        #expect(note.transferText == "Plan\n\nShip it")
    }
}
