import Foundation
import Testing
@testable import Planner

struct NoteSortOrderTests {
    private let older = Date(timeIntervalSince1970: 1_700_000_000)
    private let newer = Date(timeIntervalSince1970: 1_800_000_000)

    private func file(_ name: String, modified: Date, created: Date) -> NoteFile {
        NoteFile(
            url: URL(filePath: "/Notes/\(name)"), relativePath: name, modifiedDate: modified, createdDate: created
        )
    }

    @Test func sortsByDateModifiedNewestFirst() {
        let edited = file("Edited.md", modified: newer, created: older)
        let added = file("Added.md", modified: older, created: newer)
        #expect(NoteSortOrder.dateModified.sorted([added, edited]).map(\.relativePath) == ["Edited.md", "Added.md"])
    }

    @Test func sortsByDateAddedNewestFirst() {
        let edited = file("Edited.md", modified: newer, created: older)
        let added = file("Added.md", modified: older, created: newer)
        #expect(NoteSortOrder.dateAdded.sorted([edited, added]).map(\.relativePath) == ["Added.md", "Edited.md"])
    }

    @Test func breaksTiesByPath() {
        let second = file("Note 10.md", modified: older, created: older)
        let first = file("Note 2.md", modified: older, created: older)
        #expect(NoteSortOrder.dateAdded.sorted([second, first]).map(\.relativePath) == ["Note 2.md", "Note 10.md"])
    }

    @Test func fallsBackToModifiedDateWhenCreationDateIsUnknown() {
        let unknown = NoteFile(url: URL(filePath: "/Notes/A.md"), relativePath: "A.md", modifiedDate: newer)
        #expect(unknown.createdDate == newer)
    }
}
