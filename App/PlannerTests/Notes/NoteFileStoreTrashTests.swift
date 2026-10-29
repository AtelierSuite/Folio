import Foundation
import Testing
@testable import Planner

struct NoteFileStoreTrashTests {
    @Test func movesNotesToTrashAndRestoresThemToTheirFolder() async throws {
        let directory = try TemporaryDirectory()
        try directory.write("Body", to: "Work/Meeting.md")
        let store = NoteFileStore(rootURL: directory.url)
        let url = directory.url.appending(path: "Work/Meeting.md")

        let trashedURL = try await store.moveToTrash(url)

        #expect(try await store.notes().isEmpty)
        let trashed = try await store.trashedNotes()
        #expect(trashed.map(\.relativePath) == ["Work/Meeting.md"])
        #expect(trashedURL.path().contains("/.trash/Work/"))

        let restoredURL = try await store.restore(trashed[0].url)

        #expect(restoredURL.lastPathComponent == "Meeting.md")
        #expect(try await store.read(restoredURL).text == "Body")
        #expect(try await store.trashedNotes().isEmpty)
    }

    @Test func restoringDoesNotOverwriteANewerNoteWithTheSameName() async throws {
        let directory = try TemporaryDirectory()
        let store = NoteFileStore(rootURL: directory.url)
        let original = try await store.createNote(titled: "Idea", text: "Old")
        let trashedURL = try await store.moveToTrash(original.url)
        _ = try await store.createNote(titled: "Idea", text: "New")

        let restoredURL = try await store.restore(trashedURL)

        #expect(restoredURL.lastPathComponent == "Idea 2.md")
        #expect(try await store.read(original.url).text == "New")
    }

    @Test func deletesPermanentlyAndEmptiesTrash() async throws {
        let directory = try TemporaryDirectory()
        let store = NoteFileStore(rootURL: directory.url)
        let first = try await store.createNote(titled: "First")
        let second = try await store.createNote(titled: "Second")
        let firstTrashed = try await store.moveToTrash(first.url)
        try await store.moveToTrash(second.url)

        try await store.deletePermanently(firstTrashed)
        #expect(try await store.trashedNotes().map(\.title) == ["Second"])

        try await store.emptyTrash()
        #expect(try await store.trashedNotes().isEmpty)
        await #expect(throws: NotesStorageError.notInTrash) {
            try await store.deletePermanently(directory.url.appending(path: "Other.md"))
        }
    }
}
