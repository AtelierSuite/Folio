import Foundation
import Testing
@testable import Planner

struct LinkedNoteImageTests {
    private let store = NoteFileStore(rootURL: URL(filePath: "/notes", directoryHint: .isDirectory))
    private let noteURL = URL(filePath: "/notes/Work/Standup.md")

    @Test func picksTheFirstImageStoredWithTheNotes() {
        let text = """
        ![remote](https://example.com/photo.png)
        `![code](../assets/code.png)`
        ![whiteboard](../assets/White%20board.jpg)
        ![second](../assets/second.png)
        """
        let image = LinkedNoteImage.firstLocalImage(in: text, noteURL: noteURL, store: store)
        #expect(image == URL(filePath: "/notes/assets/White board.jpg"))
    }

    @Test func ignoresImagesOutsideTheNotesFolder() {
        let text = "![escape](../../../etc/photo.png)"
        #expect(LinkedNoteImage.firstLocalImage(in: text, noteURL: noteURL, store: store) == nil)
    }

    @Test func noteWithoutImagesHasNone() {
        #expect(LinkedNoteImage.firstLocalImage(in: "# Standup\nNotes", noteURL: noteURL, store: store) == nil)
    }
}
