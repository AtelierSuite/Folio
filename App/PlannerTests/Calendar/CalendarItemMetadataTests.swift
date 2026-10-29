import Foundation
import Testing
@testable import Planner

struct CalendarItemMetadataTests {
    @Test func storesAndRemovesValues() {
        var table = CalendarItemMetadataTable<String>()
        let reference = Fixtures.reference()
        table.setValue("note-1", for: reference)
        #expect(table.value(for: reference) == "note-1")
        table.setValue(nil, for: reference)
        #expect(table.value(for: reference) == nil)
        #expect(table.entries.isEmpty)
    }

    @Test func relinkMovesEntryToCurrentReference() {
        var table = CalendarItemMetadataTable<String>()
        let stored = Fixtures.reference(external: "exchange-old")
        let current = Fixtures.reference(external: "exchange-new")
        table.setValue("note-1", for: stored)
        #expect(table.relink(to: current) == "note-1")
        #expect(table.entries.keys.sorted() == [current.storageKey])
    }

    @Test func settingValueReplacesFallbackMatch() {
        var table = CalendarItemMetadataTable<String>()
        table.setValue("first", for: Fixtures.reference(external: "old"))
        table.setValue("second", for: Fixtures.reference(external: "new"))
        #expect(table.entries.count == 1)
        #expect(table.value(for: Fixtures.reference(external: "new")) == "second")
    }

    @Test func storePersistsAcrossInstances() throws {
        let suiteName = "CalendarItemMetadataTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let reference = Fixtures.reference()
        CalendarItemMetadataStore<Int>(key: "Metadata", defaults: defaults).setValue(42, for: reference)
        let reloaded = CalendarItemMetadataStore<Int>(key: "Metadata", defaults: defaults)
        #expect(reloaded.value(for: Fixtures.reference(local: "other-device")) == 42)
    }
}
