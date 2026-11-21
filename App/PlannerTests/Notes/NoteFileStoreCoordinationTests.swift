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
}
