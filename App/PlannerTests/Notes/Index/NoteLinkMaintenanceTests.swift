import Foundation
import Synchronization
import Testing
@testable import Planner

@MainActor
struct NoteLinkMaintenanceTests {
    private let directory: TemporaryDirectory
    private let library: NotesLibrary
    private let source: FakeCalendarDataSource
    private let store: CalendarStore
    private let maintenance: NoteLinkMaintenance
    private let event = Fixtures.event(local: "standup", start: Fixtures.date(2026, 10, 29, hour: 9))

    init() async throws {
        directory = try TemporaryDirectory()
        let defaults = try #require(UserDefaults(suiteName: "NoteLinkMaintenanceTests.\(UUID().uuidString)"))
        let settings = NotesStorageSettings(defaults: defaults)
        settings.mode = .onMyDevice
        library = NotesLibrary(settings: settings)
        await library.start()
        try await library.switchMode(
            to: .customFolder, folderURL: try directory.makeSubdirectory("Vault"), migratingNotes: false
        )
        source = FakeCalendarDataSource(events: [event], calendars: [Fixtures.plannerCalendar("calendar-1")])
        store = CalendarStore(source: source, visibilityStorage: try IntentTestSupport.visibilityStorage())
        maintenance = NoteLinkMaintenance(library: library, calendarStore: store)
    }

    @Test func keepsTheLinkWhileTheEventExists() async throws {
        _ = try await library.createNote(for: event)
        await maintenance.checkLinkedEvents(now: .now.addingTimeInterval(NoteLinkMaintenance.missingEventGrace * 2))
        #expect(library.linkedNote(for: event) != nil)
    }

    @Test func unlinksOnlyOnceTheEventHasBeenGoneLongEnough() async throws {
        let url = try await library.createNote(for: event)
        source.replaceEvents([])
        let now = Date.now
        await maintenance.checkLinkedEvents(now: now)
        #expect(library.eventLink(forNote: url) != nil)
        await maintenance.checkLinkedEvents(now: now.addingTimeInterval(NoteLinkMaintenance.missingEventGrace + 1))
        #expect(library.eventLink(forNote: url) == nil)
    }

    @Test func forgetsAMissedEventThatComesBack() async throws {
        let url = try await library.createNote(for: event)
        source.replaceEvents([])
        let now = Date.now
        await maintenance.checkLinkedEvents(now: now)
        source.replaceEvents([event])
        await maintenance.checkLinkedEvents(now: now.addingTimeInterval(60))
        source.replaceEvents([])
        await maintenance.checkLinkedEvents(now: now.addingTimeInterval(NoteLinkMaintenance.missingEventGrace + 1))
        #expect(library.eventLink(forNote: url) != nil)
    }

    @Test func keepsLinksWhenTheEventsCalendarIsGone() async throws {
        let url = try await library.createNote(for: event)
        source.replaceEvents([])
        source.state.withLock { $0.calendars = [] }
        store.reloadCalendars()
        let now = Date.now
        await maintenance.checkLinkedEvents(now: now)
        await maintenance.checkLinkedEvents(now: now.addingTimeInterval(NoteLinkMaintenance.missingEventGrace + 1))
        #expect(library.eventLink(forNote: url) != nil)
    }
}
