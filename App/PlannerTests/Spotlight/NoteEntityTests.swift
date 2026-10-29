import CoreSpotlight
import Foundation
import Testing
@testable import Planner

struct NoteEntityTests {
    @Test func indexesTheTitlePlainTextTagsAndDate() throws {
        let url = URL(filePath: "/Notes/Projects/Launch.md")
        let modifiedDate = Date(timeIntervalSince1970: 1_800_000_000)
        let note = Note(url: url, modifiedDate: modifiedDate, text: """
        ---
        date: 2026-10-29
        tags: [work, launch]
        ---
        # Launch **checklist**
        - [ ] Book the [venue](https://example.com)
        """)

        let entity = NoteEntity(note: note, relativePath: "Projects/Launch.md")
        let attributes = entity.attributeSet

        #expect(entity.id == "Projects/Launch.md")
        #expect(attributes.title == "Launch")
        #expect(attributes.textContent == "Launch checklist\nBook the venue")
        #expect(attributes.contentDescription == "Launch checklist Book the venue")
        #expect(attributes.keywords == ["work", "launch"])
        #expect(attributes.contentCreationDate == entity.date)
        #expect(entity.date != nil)
        #expect(attributes.contentModificationDate == modifiedDate)
    }

    @Test func evictedNotesAreIndexedByTitleOnly() async throws {
        let directory = try TemporaryDirectory()
        let store = NoteFileStore(rootURL: directory.url)
        let file = NoteFile(
            url: directory.url.appending(path: "Remote.md"), relativePath: "Remote.md",
            modifiedDate: .now, isDownloaded: false
        )

        let entity = await store.entity(for: file)

        #expect(entity.title == "Remote")
        #expect(entity.plainText.isEmpty)
    }
}
