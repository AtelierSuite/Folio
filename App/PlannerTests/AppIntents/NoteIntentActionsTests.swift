import Foundation
import Testing
@testable import Planner

@MainActor
struct NoteIntentActionsTests {
    private let directory: TemporaryDirectory
    private let library: NotesLibrary
    private let actions: NoteIntentActions

    init() async throws {
        directory = try TemporaryDirectory()
        let defaults = try #require(UserDefaults(suiteName: "NoteIntentActionsTests.\(UUID().uuidString)"))
        let settings = NotesStorageSettings(defaults: defaults)
        settings.mode = .onMyDevice
        library = NotesLibrary(settings: settings)
        await library.start()
        try await library.switchMode(
            to: .customFolder, folderURL: try directory.makeSubdirectory("Vault"), migratingNotes: false
        )
        actions = NoteIntentActions(library: library)
    }

    @Test func createsANoteAndReturnsItsEntity() async throws {
        let entity = try await actions.createNote(titled: " Trip ideas ", text: "Kyoto")

        #expect(entity.id == "Trip ideas.md")
        #expect(entity.title == "Trip ideas")
        #expect(try await library.read(entity.url).text == "Kyoto")
        await #expect(throws: PlannerIntentError.emptyTitle) {
            try await actions.createNote(titled: "  ")
        }
    }

    @Test func appendsOnANewLine() async throws {
        let entity = try await actions.createNote(titled: "Groceries", text: "- Eggs")

        _ = try await actions.append("- Milk", to: entity)
        _ = try await actions.append("  - Bread \n", to: entity)

        #expect(try await library.read(entity.url).text == "- Eggs\n- Milk\n- Bread\n")
    }

    @Test func appendingToTodaysNoteCreatesItOnce() async throws {
        let day = Fixtures.date(2026, 10, 29, hour: 12)

        let first = try await actions.appendToDailyNote("Called the bank", on: day)
        let second = try await actions.appendToDailyNote("Booked flights", on: day)

        #expect(first.id == DailyNoteNaming.relativePath(for: day))
        #expect(second.id == first.id)
        let text = try await library.read(second.url).text
        #expect(text.hasSuffix("Called the bank\nBooked flights\n"))
        #expect(MarkdownNoteFile(contents: text).frontMatter.value(forKey: MarkdownFrontMatter.dateKey) != nil)
    }

    @Test func editingReplacesTheBodyKeepsFrontMatterAndRenames() async throws {
        let entity = try await actions.createNote(titled: "Draft", text: "---\ntags: [work]\n---\nOld text\n")

        let edited = try await actions.edit(entity, newTitle: "Final", newText: "New text")

        #expect(edited.title == "Final")
        #expect(try await library.read(edited.url).text == "---\ntags: [work]\n---\nNew text\n")
        #expect(library.notes.map(\.title) == ["Final"])
    }

    @Test func movesNotesToTheTrashAndReportsMissingOnes() async throws {
        let entity = try await actions.createNote(titled: "Old")

        try await actions.moveToTrash(entity)

        #expect(library.notes.isEmpty)
        #expect(library.trashedNotes.map(\.title) == ["Old"])
        await #expect(throws: PlannerIntentError.noteNotFound) {
            try await actions.append("More", to: entity)
        }
    }
}
