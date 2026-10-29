import Foundation
import Testing
@testable import Planner

@MainActor
struct NotesLibraryIndexingTests {
    private let directory: TemporaryDirectory
    private let index = FakeNoteSearchIndex()
    private let settings: NotesStorageSettings

    init() throws {
        directory = try TemporaryDirectory()
        let suiteName = "PlannerTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        settings = NotesStorageSettings(defaults: defaults)
        settings.mode = .onMyDevice
    }

    private func makeLibrary() -> NotesLibrary {
        let indexer = NoteSpotlightIndexer(index: index, manifestURL: directory.url.appending(path: "Manifest.json"))
        return NotesLibrary(settings: settings, searchIndexer: indexer)
    }

    @Test func keepsTheIndexInSyncWithLibraryChanges() async throws {
        let library = makeLibrary()
        await library.start()
        try await library.switchMode(
            to: .customFolder, folderURL: try directory.makeSubdirectory("Vault"), migratingNotes: false
        )

        let note = try await library.createNote(titled: "Plan", text: "tags-free body")
        await library.waitForIndexing()
        #expect(await index.entities.keys.sorted() == ["Plan.md"])

        let renamedURL = try await library.rename(note.url, to: "Roadmap")
        await library.waitForIndexing()
        #expect(await index.entities.keys.sorted() == ["Roadmap.md"])

        try await library.moveToTrash(renamedURL)
        await library.waitForIndexing()
        #expect(await index.entities.isEmpty)
    }

    @Test func switchingStorageModesReplacesTheIndexedNotes() async throws {
        let library = makeLibrary()
        await library.start()
        let firstFolder = try directory.makeSubdirectory("First")
        let secondFolder = try directory.makeSubdirectory("Second")
        try directory.write("One", to: "One.md", in: firstFolder)
        try directory.write("Two", to: "Two.md", in: secondFolder)

        try await library.switchMode(to: .customFolder, folderURL: firstFolder, migratingNotes: false)
        await library.waitForIndexing()
        #expect(await index.entities.keys.sorted() == ["One.md"])

        try await library.switchMode(to: .customFolder, folderURL: secondFolder, migratingNotes: false)
        await library.waitForIndexing()
        #expect(await index.entities.keys.sorted() == ["Two.md"])
    }

    @Test func losingAccessToTheChosenFolderClearsTheIndex() async throws {
        let folderURL = try directory.makeSubdirectory("Removable")
        try directory.write("Secret", to: "Secret.md", in: folderURL)
        let library = makeLibrary()
        await library.start()
        try await library.switchMode(to: .customFolder, folderURL: folderURL, migratingNotes: false)
        await library.waitForIndexing()
        #expect(await index.entities.keys.sorted() == ["Secret.md"])

        try FileManager.default.removeItem(at: folderURL)
        let relaunched = makeLibrary()
        await relaunched.start()
        await relaunched.waitForIndexing()

        #expect(relaunched.status == .folderUnavailable)
        #expect(await index.entities.isEmpty)
    }

    @Test func resolvesEntitiesByTheirRelativePath() async throws {
        let folderURL = try directory.makeSubdirectory("Lookup")
        try directory.write("# Found it", to: "Projects/Found.md", in: folderURL)
        let library = makeLibrary()
        await library.start()
        try await library.switchMode(to: .customFolder, folderURL: folderURL, migratingNotes: false)

        let entities = await library.noteEntities(for: ["Projects/Found.md", "Missing.md", "../Escape.md"])

        #expect(entities.map(\.id) == ["Projects/Found.md"])
        #expect(entities.first?.plainText == "Found it")
        #expect(library.noteURL(forEntityIdentifier: "Projects/Found.md")?.lastPathComponent == "Found.md")
        #expect(await library.noteEntities(matching: "fou").map(\.id) == ["Projects/Found.md"])
    }
}
