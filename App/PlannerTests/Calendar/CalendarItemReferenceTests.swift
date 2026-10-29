import Foundation
import Testing
@testable import Planner

struct CalendarItemReferenceTests {
    @Test func storageKeyUsesExternalIdentifierAndOccurrence() {
        let occurrence = Fixtures.date(2026, 10, 29, hour: 9)
        let reference = Fixtures.reference(occurrence: occurrence)
        #expect(reference.storageKey == "external-1@\(Int(occurrence.timeIntervalSince1970))")
    }

    @Test func storageKeyFallsBackToLocalIdentifier() {
        #expect(Fixtures.reference(external: nil).storageKey == "local:local-1")
        #expect(Fixtures.reference(external: "").storageKey == "local:local-1")
    }

    @Test func matchesSameExternalIdentifierFromAnotherDevice() {
        let stored = Fixtures.reference(local: "device-a")
        let current = Fixtures.reference(local: "device-b")
        #expect(current.bestMatch(in: [stored]) == stored)
    }

    @Test func prefersLocalIdentifierAmongDuplicatedExternalIdentifiers() {
        let original = Fixtures.reference(local: "original")
        let duplicate = Fixtures.reference(local: "duplicate", calendarIdentifier: "calendar-2")
        #expect(original.bestMatch(in: [duplicate, original]) == original)
    }

    @Test func fallsBackToLocalIdentifierWhenExternalIdentifierChanges() {
        let stored = Fixtures.reference(external: "exchange-old")
        let current = Fixtures.reference(external: "exchange-new")
        #expect(current.bestMatch(in: [stored]) == stored)
    }

    @Test func fallsBackToTitleCalendarAndStartWhenBothIdentifiersChange() {
        let stored = Fixtures.reference(external: "old", local: "old")
        let current = Fixtures.reference(external: "new", local: "new")
        #expect(current.bestMatch(in: [stored]) == stored)
    }

    @Test func doesNotMatchAnotherOccurrenceOfTheSameSeries() {
        let monday = Fixtures.reference(occurrence: Fixtures.date(2026, 10, 26, hour: 9))
        let tuesday = Fixtures.reference(occurrence: Fixtures.date(2026, 10, 27, hour: 9))
        #expect(tuesday.bestMatch(in: [monday]) == nil)
    }

    @Test func doesNotMatchUnrelatedItem() {
        let stored = Fixtures.reference(external: "other", local: "other", title: "Lunch")
        #expect(Fixtures.reference().bestMatch(in: [stored]) == nil)
    }
}
