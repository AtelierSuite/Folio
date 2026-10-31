import Foundation
import Testing
@testable import Planner

@MainActor
struct NotesLibraryLinkingTests {
    private let directory: TemporaryDirectory
    private let library: NotesLibrary
    private let event = Fixtures.event(local: "standup", start: Fixtures.date(2026, 10, 29, hour: 9))

    init() async throws {
        directory = try TemporaryDirectory()
        let defaults = try #require(UserDefaults(suiteName: "NotesLibraryLinkingTests.\(UUID().uuidString)"))
        let settings = NotesStorageSettings(defaults: defaults)
        settings.mode = .onMyDevice
        library = NotesLibrary(settings: settings)
        await library.start()
        try await library.switchMode(
            to: .customFolder, folderURL: try directory.makeSubdirectory("Vault"), migratingNotes: false
        )
    }

    @Test func createsAnEventNoteWithoutFrontMatterAndLinksIt() async throws {
        let url = try await library.createNote(for: event)
        #expect(try await library.read(url).text == "# standup\n")
        #expect(library.linkedNote(for: event)?.url == url)
        #expect(library.eventLink(forNote: url)?.event.eventKey == event.reference.storageKey)
        #expect(try await library.createNote(for: event) == url)
    }

    @Test func keepsTheLinkThroughRenameTrashAndRestore() async throws {
        let url = try await library.createNote(for: event)
        let renamed = try await library.rename(url, to: "Agenda")
        #expect(library.linkedNote(for: event)?.url == renamed)
        let trashed = try await library.moveToTrash(renamed)
        #expect(library.linkedNote(for: event) == nil)
        let restored = try await library.restore(trashed)
        #expect(library.linkedNote(for: event)?.url == restored)
    }

    @Test func deletingANoteForGoodRemovesItsLink() async throws {
        var removed: [NoteLink] = []
        library.onLinksRemoved = { removed += $0 }
        let url = try await library.createNote(for: event)
        try await library.deletePermanently(try await library.moveToTrash(url))
        #expect(removed.map(\.event.eventKey) == [event.reference.storageKey])
        #expect(library.noteLinks.isEmpty)
    }

    @Test func dropsLinksOfNotesDeletedElsewhereOnlyAfterADay() async throws {
        var removed: [NoteLink] = []
        library.onLinksRemoved = { removed += $0 }
        let url = try await library.createNote(for: event)
        try FileManager.default.removeItem(at: url)
        await library.refresh()
        let now = Date.now
        library.reconcileLinks(now: now)
        #expect(removed.isEmpty)
        library.reconcileLinks(now: now.addingTimeInterval(NotesLibrary.missingNoteGrace + 1))
        #expect(removed.count == 1)
        #expect(library.noteLinks.isEmpty)
    }

    @Test func unlinksANoteByHand() async throws {
        var removed: [NoteLink] = []
        library.onLinksRemoved = { removed += $0 }
        let url = try await library.createNote(for: event)
        library.unlink(url)
        #expect(library.linkedNote(for: event) == nil)
        #expect(removed.count == 1)
    }
}
