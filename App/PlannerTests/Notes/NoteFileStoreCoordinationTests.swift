import Foundation
import Testing
@testable import Planner

struct NoteFileStoreCoordinationTests {
    @Test func listsNotesWithoutWaitingForAWriterOnTheFolder() async throws {
        let directory = try TemporaryDirectory()
        try directory.write("A", to: "Alpha.md")
        let store = NoteFileStore(rootURL: directory.url)
        let held = HeldFileCoordination(writingAt: directory.url)
        let releaseTask = Task.detached {
            try? await Task.sleep(for: .seconds(2))
            held.release()
        }

        let notes = try await store.notes()

        #expect(!held.hasReleased)
        #expect(notes.map(\.title) == ["Alpha"])
        held.release()
        releaseTask.cancel()
    }

    @Test func listsTheTrashWithoutWaitingForAWriterOnIt() async throws {
        let directory = try TemporaryDirectory()
        try directory.write("A", to: ".trash/Alpha.md")
        let store = NoteFileStore(rootURL: directory.url)
        let held = HeldFileCoordination(writingAt: store.trashURL)
        let releaseTask = Task.detached {
            try? await Task.sleep(for: .seconds(2))
            held.release()
        }

        let trashed = try await store.trashedNotes()

        #expect(!held.hasReleased)
        #expect(trashed.map(\.title) == ["Alpha"])
        held.release()
        releaseTask.cancel()
    }

    @Test func savesOnceAWriterOnTheNoteLetsGo() async throws {
        let directory = try TemporaryDirectory()
        let store = NoteFileStore(rootURL: directory.url)
        let note = try await store.createNote(titled: "Draft", text: "One")
        let held = HeldFileCoordination(writingAt: note.url)
        let releaseTask = Task.detached {
            try? await Task.sleep(for: .milliseconds(500))
            held.release()
        }

        let result = try await store.save("Two", over: note)

        #expect(held.hasReleased)
        guard case .saved(let saved) = result else {
            Issue.record("Expected a save, got \(result)")
            return
        }
        #expect(saved.text == "Two")
        #expect(try await store.read(note.url).text == "Two")
        releaseTask.cancel()
    }

    @Test func finishesASaveEvenWhenItsTaskIsCancelled() async throws {
        let directory = try TemporaryDirectory()
        let store = NoteFileStore(rootURL: directory.url)
        let note = try await store.createNote(titled: "Draft", text: "One")
        let held = HeldFileCoordination(writingAt: note.url)

        let saveTask = Task.detached { try await store.save("Two", over: note) }
        try await Task.sleep(for: .milliseconds(300))
        saveTask.cancel()
        held.release()
        _ = try await saveTask.value

        #expect(try await store.read(note.url).text == "Two")
    }
}
