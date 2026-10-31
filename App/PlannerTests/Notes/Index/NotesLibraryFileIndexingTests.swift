import Foundation
import Testing
@testable import Planner

@MainActor
struct NotesLibraryFileIndexingTests {
    private let directory: TemporaryDirectory
    private let vault: URL
    private let library: NotesLibrary

    init() async throws {
        directory = try TemporaryDirectory()
        let defaults = try #require(UserDefaults(suiteName: "NotesLibraryFileIndexingTests.\(UUID().uuidString)"))
        let settings = NotesStorageSettings(defaults: defaults)
        settings.mode = .onMyDevice
        library = NotesLibrary(settings: settings)
        await library.start()
        vault = try directory.makeSubdirectory("Vault")
        try await library.switchMode(to: .customFolder, folderURL: vault, migratingNotes: false)
    }

    private func write(_ text: String, to relativePath: String) throws {
        let url = vault.appending(path: relativePath)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(text.utf8).write(to: url)
    }

    @Test func movesFrontMatterLinksIntoTheIndexAndStripsThem() async throws {
        try write("---\nevent: external-1\ndate: 2026-10-29\ntags: [work]\n---\n# Agenda\n", to: "Agenda.md")
        await library.refresh()
        await library.indexFiles()
        let url = vault.appending(path: "Agenda.md")
        #expect(try await library.read(url).text == "# Agenda\n")
        let link = try #require(library.eventLink(forNote: url))
        #expect(link.event.eventKey == "external-1")
        #expect(link.event.dayKey == "2026-10-29")
    }
}
