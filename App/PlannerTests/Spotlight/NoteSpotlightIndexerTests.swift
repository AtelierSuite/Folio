import Foundation
import Testing
@testable import Planner

struct NoteSpotlightIndexerTests {
    private let directory: TemporaryDirectory
    private let index = FakeNoteSearchIndex()
    private let indexer: NoteSpotlightIndexer
    private let store: NoteFileStore

    init() throws {
        directory = try TemporaryDirectory()
        let rootURL = try directory.makeSubdirectory("Notes")
        store = NoteFileStore(rootURL: rootURL)
        indexer = NoteSpotlightIndexer(index: index, manifestURL: directory.url.appending(path: "Manifest.json"))
    }

    @Test func firstSyncClearsStaleItemsAndIndexesEveryNote() async throws {
        _ = try await store.createNote(titled: "Alpha", text: "# Hello *world*")
        _ = try await store.createNote(titled: "Beta", text: "Body")

        await indexer.sync(try await store.notes(), in: store)

        #expect(await index.operations == [.deleteAll, .index(["Alpha.md", "Beta.md"])])
        #expect(await index.entities["Alpha.md"]?.plainText == "Hello world")
    }

    @Test func unchangedNotesAreNotReindexed() async throws {
        _ = try await store.createNote(titled: "Alpha", text: "One")
        await indexer.sync(try await store.notes(), in: store)
        await index.clearOperations()

        await indexer.sync(try await store.notes(), in: store)

        #expect(await index.operations.isEmpty)
    }

    @Test func editedNotesAreReindexed() async throws {
        let alpha = try await store.createNote(titled: "Alpha", text: "One")
        _ = try await store.createNote(titled: "Beta", text: "Two")
        await indexer.sync(try await store.notes(), in: store)
        await index.clearOperations()
        try await Task.sleep(for: .milliseconds(20))

        _ = try await store.save("One, edited", over: alpha)
        await indexer.sync(try await store.notes(), in: store)

        #expect(await index.operations == [.index(["Alpha.md"])])
        #expect(await index.entities["Alpha.md"]?.plainText == "One, edited")
    }

    @Test func renamedNotesReplaceTheirOldItem() async throws {
        let alpha = try await store.createNote(titled: "Alpha", text: "One")
        await indexer.sync(try await store.notes(), in: store)
        await index.clearOperations()

        _ = try await store.rename(alpha.url, to: "Omega")
        await indexer.sync(try await store.notes(), in: store)

        #expect(await index.operations == [.delete(["Alpha.md"]), .index(["Omega.md"])])
        #expect(await index.entities.keys.sorted() == ["Omega.md"])
    }

    @Test func trashedNotesAreRemoved() async throws {
        let alpha = try await store.createNote(titled: "Alpha", text: "One")
        _ = try await store.createNote(titled: "Beta", text: "Two")
        await indexer.sync(try await store.notes(), in: store)
        await index.clearOperations()

        try await store.moveToTrash(alpha.url)
        await indexer.sync(try await store.notes(), in: store)

        #expect(await index.operations == [.delete(["Alpha.md"])])
        #expect(await index.entities.keys.sorted() == ["Beta.md"])
    }

    @Test func switchingToAnotherFolderReindexesFromScratch() async throws {
        _ = try await store.createNote(titled: "Alpha", text: "One")
        await indexer.sync(try await store.notes(), in: store)
        await index.clearOperations()
        let otherStore = NoteFileStore(rootURL: try directory.makeSubdirectory("Other"))
        _ = try await otherStore.createNote(titled: "Gamma", text: "Three")

        await indexer.sync(try await otherStore.notes(), in: otherStore)

        #expect(await index.operations == [.deleteAll, .index(["Gamma.md"])])
        #expect(await index.entities.keys.sorted() == ["Gamma.md"])
    }

    @Test func downloadedNotesAreReindexedWithTheirContent() async throws {
        let url = store.rootURL.appending(path: "Remote.md")
        let evicted = NoteFile(url: url, relativePath: "Remote.md", modifiedDate: .distantPast, isDownloaded: false)
        await indexer.sync([evicted], in: store)
        await index.clearOperations()
        try directory.write("Downloaded body", to: "Remote.md", in: store.rootURL)

        let downloaded = NoteFile(url: url, relativePath: "Remote.md", modifiedDate: .distantPast)
        await indexer.sync([downloaded], in: store)

        #expect(await index.operations == [.index(["Remote.md"])])
        #expect(await index.entities["Remote.md"]?.plainText == "Downloaded body")
    }

    @Test func removingAllClearsTheIndexOnce() async throws {
        _ = try await store.createNote(titled: "Alpha", text: "One")
        await indexer.sync(try await store.notes(), in: store)
        await index.clearOperations()

        await indexer.removeAll()
        await indexer.removeAll()
        await indexer.sync(try await store.notes(), in: store)

        #expect(await index.operations == [.deleteAll, .deleteAll, .index(["Alpha.md"])])
    }
}
