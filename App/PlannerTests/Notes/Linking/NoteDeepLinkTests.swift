import Foundation
import Testing
@testable import Planner

struct NoteDeepLinkTests {
    @Test func roundTripsRelativePathsWithSpacesAndFolders() throws {
        let url = try #require(NoteDeepLink.url(forRelativePath: "Daily/Team Sync 2026-10-29.md"))
        #expect(url.absoluteString == "folio://note/Daily/Team%20Sync%202026-10-29.md")
        #expect(NoteDeepLink.relativePath(from: url) == "Daily/Team Sync 2026-10-29.md")
    }

    @Test func rejectsOtherLinksAndPathsLeavingTheFolder() throws {
        #expect(NoteDeepLink.relativePath(from: try #require(URL(string: "folio://calendar/2026"))) == nil)
        #expect(NoteDeepLink.relativePath(from: try #require(URL(string: "https://note/A.md"))) == nil)
        #expect(NoteDeepLink.relativePath(from: try #require(URL(string: "folio://note/"))) == nil)
        #expect(NoteDeepLink.relativePath(from: try #require(URL(string: "folio://note/../secret.md"))) == nil)
    }
}
