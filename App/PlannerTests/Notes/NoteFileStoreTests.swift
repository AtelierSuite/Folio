import Foundation
import Testing
@testable import Planner

struct NoteFileStoreTests {
    @Test func listsMarkdownNotesAndSkipsTrashAssetsAndHiddenFiles() async throws {
        let directory = try TemporaryDirectory()
        try directory.write("A", to: "Alpha.md")
        try directory.write("B", to: "Projects/Beta.markdown")
        try directory.write("C", to: ".trash/Gamma.md")
        try directory.write("D", to: "assets/Delta.md")
        try directory.write("E", to: ".obsidian/Epsilon.md")
        try directory.write("F", to: "image.png")
        try directory.write("G", to: ".hidden.md")
        let store = NoteFileStore(rootURL: directory.url)

        let notes = try await store.notes()

        #expect(Set(notes.map(\.relativePath)) == ["Alpha.md", "Projects/Beta.markdown"])
        #expect(Set(notes.map(\.title)) == ["Alpha", "Beta"])
        #expect(notes.first { $0.title == "Beta" }?.folderPath == "Projects")
    }

    @Test func listsEvictedICloudPlaceholdersUnderTheirRealName() async throws {
        let directory = try TemporaryDirectory()
        try directory.write("", to: ".Remote.md.icloud")
        let store = NoteFileStore(rootURL: directory.url)

        let notes = try await store.notes()

        #expect(notes.map(\.title) == ["Remote"])
        #expect(notes.first?.isDownloaded == false)
        #expect(notes.first?.url.lastPathComponent == "Remote.md")
    }

    @Test func createsNotesWithUniqueSanitizedNames() async throws {
        let directory = try TemporaryDirectory()
        let store = NoteFileStore(rootURL: directory.url)

        let first = try await store.createNote(titled: "Plans/2026", text: "# Plans")
        let second = try await store.createNote(titled: "Plans/2026")

        #expect(first.url.lastPathComponent == "Plans 2026.md")
        #expect(second.url.lastPathComponent == "Plans 2026 2.md")
        #expect(try await store.read(first.url).text == "# Plans")
        await #expect(throws: NotesStorageError.invalidTitle) {
            try await store.createNote(titled: " / ")
        }
    }

    @Test func savesWhenTheFileIsUnchangedOnDisk() async throws {
        let directory = try TemporaryDirectory()
        let store = NoteFileStore(rootURL: directory.url)
        let note = try await store.createNote(titled: "Draft", text: "One")

        let result = try await store.save("Two", over: note)

        guard case .saved(let saved) = result else {
            Issue.record("Expected a save, got \(result)")
            return
        }
        #expect(saved.text == "Two")
        #expect(try await store.read(note.url).text == "Two")
    }

    @Test func keepsBothVersionsWhenTheFileChangedElsewhere() async throws {
        let directory = try TemporaryDirectory()
        let store = NoteFileStore(rootURL: directory.url)
        let note = try await store.createNote(titled: "Shared", text: "Original")
        try directory.write("Edited on another device", to: "Shared.md")

        let result = try await store.save("Edited here", over: note)

        guard case .conflict(let current, let copyURL) = result else {
            Issue.record("Expected a conflict, got \(result)")
            return
        }
        #expect(current.text == "Edited on another device")
        #expect(try await store.read(note.url).text == "Edited on another device")
        #expect(try String(contentsOf: copyURL, encoding: .utf8) == "Edited here")
        #expect(copyURL.lastPathComponent != "Shared.md")
        #expect(try await store.notes().count == 2)
    }

    @Test func renamesWithinTheSameFolder() async throws {
        let directory = try TemporaryDirectory()
        try directory.write("A", to: "Folder/Old.md")
        try directory.write("B", to: "Folder/Taken.md")
        let store = NoteFileStore(rootURL: directory.url)
        let url = directory.url.appending(path: "Folder/Old.md")

        let renamed = try await store.rename(url, to: "Taken")

        #expect(renamed.lastPathComponent == "Taken 2.md")
        #expect(renamed.deletingLastPathComponent().lastPathComponent == "Folder")
        #expect(try await store.read(renamed).text == "A")
        #expect(try await store.rename(renamed, to: "taken 2").lastPathComponent == "taken 2.md")
    }
}
