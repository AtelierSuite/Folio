import Foundation
import Testing
@testable import Planner

struct NoteFileStoreAssetTests {
    @Test func storesAssetsInTheSharedAssetsFolderWithRelativeLinks() async throws {
        let directory = try TemporaryDirectory()
        let store = NoteFileStore(rootURL: directory.url)
        let rootNote = directory.url.appending(path: "Root.md")
        let nestedNote = directory.url.appending(path: "Trips/Japan/Kyoto.md")

        let firstLink = try await store.addAsset(Data([1]), named: "photo.png", for: rootNote)
        let secondLink = try await store.addAsset(Data([2]), named: "photo.png", for: nestedNote)

        #expect(firstLink == "assets/photo.png")
        #expect(secondLink == "../../assets/photo 2.png")
        #expect(try Data(contentsOf: store.resolveLink(secondLink, from: nestedNote)) == Data([2]))
        #expect(store.resolveLink("assets/photo%202.png", from: rootNote).lastPathComponent == "photo 2.png")
    }
}
