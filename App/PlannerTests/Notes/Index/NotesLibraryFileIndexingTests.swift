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

    private func exists(_ relativePath: String) -> Bool {
        FileManager.default.fileExists(atPath: vault.appending(path: relativePath).path(percentEncoded: false))
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

    @Test func removesOnlyImagesNoNoteHasMentionedForAWeek() async throws {
        try write("![Cat](assets/cat.png)", to: "Pets.md")
        try write("![[dog.png]]", to: "\(NoteFileStore.trashFolderName)/Old.md")
        for name in ["cat.png", "dog.png", "unused.png"] {
            try write("image", to: "assets/\(name)")
        }
        await library.refresh()
        let now = Date.now
        await library.indexFiles(now: now)
        #expect(exists("assets/unused.png"))
        await library.indexFiles(now: now.addingTimeInterval(NotesLibrary.unusedAssetGrace + 1))
        #expect(!exists("assets/unused.png"))
        #expect(exists("assets/cat.png"))
        #expect(exists("assets/dog.png"))
    }

    @Test func keepsAnImageThatIsMentionedAgainBeforeTheWeekIsUp() async throws {
        try write("text", to: "Pets.md")
        try write("image", to: "assets/cat.png")
        await library.refresh()
        let now = Date.now
        await library.indexFiles(now: now)
        try write("![Cat](assets/cat.png)", to: "Pets.md")
        await library.refresh()
        await library.indexFiles(now: now.addingTimeInterval(60))
        try write("text again", to: "Pets.md")
        await library.refresh()
        await library.indexFiles(now: now.addingTimeInterval(NotesLibrary.unusedAssetGrace + 120))
        #expect(exists("assets/cat.png"))
    }
}
