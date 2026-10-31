import Foundation
import Testing
@testable import Planner

struct MarkdownNoteFileSharingTests {
    @Test func sharesMarkdownWithoutFrontMatter() {
        #expect(MarkdownNoteFile.shareableMarkdown(from: "---\nevent: key\n---\n\n# Title") == "# Title")
        #expect(MarkdownNoteFile.shareableMarkdown(from: "plain") == "plain")
    }
}
