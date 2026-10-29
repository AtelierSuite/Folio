import Foundation
import Testing
@testable import Planner

@MainActor
struct NotesStorageSettingsTests {
    private func makeSettings() throws -> NotesStorageSettings {
        let suiteName = "PlannerTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        return NotesStorageSettings(defaults: defaults)
    }

    @Test func persistsTheChosenModeOnFirstLaunch() throws {
        let settings = try makeSettings()

        let library = NotesLibrary(settings: settings)

        #expect(settings.mode == library.mode)
    }

    @Test func switchingToAFolderMigratesNotesAndRemembersTheFolder() async throws {
        let directory = try TemporaryDirectory()
        let folderURL = try directory.makeSubdirectory("Vault")
        let settings = try makeSettings()
        settings.mode = .onMyDevice
        let library = NotesLibrary(settings: settings)
        await library.start()
        let note = try await library.createNote(titled: "Migrated \(UUID().uuidString)")

        let summary = try await library.switchMode(to: .customFolder, folderURL: folderURL, migratingNotes: true)

        #expect(summary.copiedFileCount >= 1)
        #expect(library.mode == .customFolder)
        #expect(library.status == .ready)
        #expect(library.notes.contains { $0.title == note.title })
        #expect(settings.mode == .customFolder)
        #expect(settings.folderBookmark != nil)

        let relaunched = NotesLibrary(settings: settings)
        await relaunched.start()
        #expect(relaunched.store?.rootURL.lastPathComponent == "Vault")
        #expect(relaunched.notes.contains { $0.title == note.title })
    }

    @Test func showsAnUnavailableStateWithoutAFolder() async throws {
        let settings = try makeSettings()
        settings.mode = .customFolder
        let library = NotesLibrary(settings: settings)

        await library.start()

        #expect(library.status == .folderUnavailable)
        #expect(library.notes.isEmpty)
        await #expect(throws: NotesStorageError.folderNotChosen) {
            try await library.createNote(titled: "Nowhere")
        }
    }

    @Test func showsAnUnavailableStateWhenTheChosenFolderIsGone() async throws {
        let directory = try TemporaryDirectory()
        let folderURL = try directory.makeSubdirectory("Removed")
        let settings = try makeSettings()
        settings.mode = .onMyDevice
        let library = NotesLibrary(settings: settings)
        await library.start()
        try await library.switchMode(to: .customFolder, folderURL: folderURL, migratingNotes: false)
        try FileManager.default.removeItem(at: folderURL)

        let relaunched = NotesLibrary(settings: settings)
        await relaunched.start()

        #expect(relaunched.status == .folderUnavailable)
    }
}
