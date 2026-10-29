import Foundation
import Testing
@testable import Planner

struct CalendarItemDragPayloadTests {
    @Test func roundTrips() {
        let payload = CalendarItemDragPayload(
            entryIdentifier: "ABC-123@815000000.0", sourceDay: Date(timeIntervalSinceReferenceDate: 815_000_000)
        )
        #expect(CalendarItemDragPayload(payload.string) == payload)
    }

    @Test func keepsIdentifiersWithSeparators() {
        let payload = CalendarItemDragPayload(entryIdentifier: "reminder:a|b", sourceDay: .distantPast)
        #expect(CalendarItemDragPayload(payload.string)?.entryIdentifier == "reminder:a|b")
    }

    @Test func ignoresOtherText() {
        #expect(CalendarItemDragPayload("Hello") == nil)
        #expect(CalendarItemDragPayload("folio-calendar-item:nope|x") == nil)
        #expect(CalendarItemDragPayload("folio-calendar-item:12|") == nil)
    }
}
