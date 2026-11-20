import Foundation
import Testing
@testable import Planner

@MainActor
struct NoteEditingSessionTests {
    private let directory: TemporaryDirectory
    private let settings: NotesStorageSettings

    init() throws {
        directory = try TemporaryDirectory()
        let suiteName = "PlannerTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        settings = NotesStorageSettings(defaults: defaults)
        settings.mode = .onMyDevice
    }

    private func makeSession(saveDelay: Duration = .seconds(60)) async throws -> NoteEditingSession {
        let library = NotesLibrary(settings: settings)
        await library.start()
        try await library.switchMode(
            to: .customFolder, folderURL: try directory.makeSubdirectory("Vault"), migratingNotes: false
        )
        let note = try await library.createNote(titled: "Draft")
        let session = NoteEditingSession(url: note.url, library: library, saveDelay: saveDelay)
        await session.load()
        return session
    }

    private func savedText(of session: NoteEditingSession) throws -> String {
        try String(contentsOf: session.url, encoding: .utf8)
    }

    @Test func overlappingSavesKeepTheLatestTextWithoutAConflict() async throws {
        let session = try await makeSession()

        session.text = "First"
        let firstSave = Task { await session.flush() }
        await Task.yield()
        session.text = "First and second"
        await session.flush()
        _ = await firstSave.value

        #expect(session.conflictedCopyURL == nil)
        #expect(session.text == "First and second")
        #expect(!session.hasUnsavedChanges)
        #expect(try savedText(of: session) == "First and second")
    }

    @Test func flushingWhileAnAutosaveRunsKeepsTheLatestText() async throws {
        let session = try await makeSession(saveDelay: .zero)

        session.text = "Typed"
        for _ in 0..<5 {
            await Task.yield()
        }
        session.text = "Typed more"
        await session.flush()

        #expect(session.conflictedCopyURL == nil)
        #expect(session.text == "Typed more")
        #expect(!session.hasUnsavedChanges)
        #expect(try savedText(of: session) == "Typed more")
    }

    @Test func aFailedSaveKeepsTheEditorAndTextUntilARetrySucceeds() async throws {
        let session = try await makeSession()
        let folderURL = session.url.deletingLastPathComponent()
        try setPermissions(0o555, of: folderURL)
        defer { try? setPermissions(0o755, of: folderURL) }

        session.text = "Kept"
        let savedWhileReadOnly = await session.flush()

        #expect(!savedWhileReadOnly)
        #expect(session.state == .ready)
        #expect(session.saveFailureMessage != nil)
        #expect(session.text == "Kept")
        #expect(session.hasUnsavedChanges)

        try setPermissions(0o755, of: folderURL)
        let savedAfterRetry = await session.flush()

        #expect(savedAfterRetry)
        #expect(session.saveFailureMessage == nil)
        #expect(try savedText(of: session) == "Kept")
    }

    private func setPermissions(_ permissions: Int, of url: URL) throws {
        try FileManager.default.setAttributes([.posixPermissions: permissions], ofItemAtPath: url.path)
    }
}
