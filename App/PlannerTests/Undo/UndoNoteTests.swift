import Foundation
import Testing
@testable import Planner

@MainActor
struct UndoNoteTests {
    @Test func deletingANoteMovesItToTheTrashAndUndoRestoresIt() async throws {
        let directory = try TemporaryDirectory()
        let suiteName = "UndoNoteTests.\(UUID().uuidString)"
        let settings = NotesStorageSettings(defaults: try #require(UserDefaults(suiteName: suiteName)))
        settings.mode = .onMyDevice
        let library = NotesLibrary(settings: settings)
        await library.start()
        try await library.switchMode(
            to: .customFolder, folderURL: try directory.makeSubdirectory("Vault"), migratingNotes: false
        )
        let note = try await library.createNote(titled: "Plan", text: "Ship undo")
        let context = try UndoTestContext(library: library)

        try await context.coordinator.moveNoteToTrash(note.url)
        #expect(library.notes.isEmpty)
        #expect(library.trashedNotes.map(\.title) == ["Plan"])
        #expect(context.coordinator.toast?.action == .delete(.note))

        context.coordinator.undoToast()
        await context.coordinator.settle()
        #expect(library.notes.map(\.title) == ["Plan"])
        #expect(library.trashedNotes.isEmpty)
        #expect(try await library.read(note.url).text == "Ship undo")

        await context.redo()
        #expect(library.notes.isEmpty)
        #expect(library.trashedNotes.map(\.title) == ["Plan"])
    }
}
