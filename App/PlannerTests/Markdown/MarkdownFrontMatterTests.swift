import Foundation
import Testing
@testable import Planner

struct MarkdownFrontMatterTests {
    private let sample = """
    ---
    # Folio note
    event: "ABC-123:456"
    date: 2026-10-29
    tags:
      - work
      - 'side project'
    mood: happy # unknown key
    nested:
      key: value
    ---
    # Body

    Text
    """

    @Test func readsKnownKeys() throws {
        let file = MarkdownNoteFile(contents: sample)
        #expect(file.frontMatter.event == "ABC-123:456")
        #expect(file.frontMatter.tags == ["work", "side project"])
        let date = try #require(file.frontMatter.date)
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: date)
        #expect(components == DateComponents(year: 2026, month: 10, day: 29, hour: 0))
        #expect(file.frontMatter.keys == ["event", "date", "tags", "mood", "nested"])
        #expect(file.frontMatter.value(forKey: "mood") == "happy")
        #expect(file.body == "# Body\n\nText")
    }

    @Test func roundTripsUnchangedFilesExactly() {
        #expect(MarkdownNoteFile(contents: sample).contents == sample)
        let plain = "# No front matter\n\n---\n\nText"
        #expect(MarkdownNoteFile(contents: plain).contents == plain)
        #expect(MarkdownNoteFile(contents: plain).frontMatter.isEmpty)
    }

    @Test func editingKnownKeysPreservesUnknownKeysVerbatim() {
        var file = MarkdownNoteFile(contents: sample)
        file.frontMatter.tags = ["work", "urgent, now"]
        file.frontMatter.event = nil
        #expect(file.contents == """
        ---
        # Folio note
        date: 2026-10-29
        tags: [work, "urgent, now"]
        mood: happy # unknown key
        nested:
          key: value
        ---
        # Body

        Text
        """)
        #expect(MarkdownNoteFile(contents: file.contents).frontMatter.tags == ["work", "urgent, now"])
    }

    @Test func addsFrontMatterToPlainFiles() throws {
        var file = MarkdownNoteFile(contents: "Hello")
        let date = try #require(Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 5)))
        file.frontMatter.date = date
        file.frontMatter.event = "true"
        file.frontMatter.tags = ["one"]
        #expect(file.contents == "---\ndate: 2026-01-05\nevent: \"true\"\ntags: [one]\n---\nHello")
        let reread = MarkdownNoteFile(contents: file.contents)
        #expect(reread.frontMatter.date == date)
        #expect(reread.frontMatter.event == "true")
    }

    @Test func writesDateTimesWithTimeZone() throws {
        var file = MarkdownNoteFile(body: "")
        let components = DateComponents(year: 2026, month: 3, day: 2, hour: 9, minute: 30)
        let date = try #require(Calendar.current.date(from: components))
        file.frontMatter.date = date
        #expect(MarkdownNoteFile(contents: file.contents).frontMatter.date == date)
        #expect(file.frontMatter.rawValue(forKey: "date")?.contains("T09:30:00") == true)
    }

    @Test func readsFlowAndCommaSeparatedTags() {
        #expect(MarkdownNoteFile(contents: "---\ntags: [a, \"b c\", 'd']\n---\n").frontMatter.tags == ["a", "b c", "d"])
        #expect(MarkdownNoteFile(contents: "---\ntags: a, b\n---\n").frontMatter.tags == ["a", "b"])
    }

    @Test func removingAllKeysDropsFrontMatter() {
        var file = MarkdownNoteFile(contents: "---\ntags: [a]\n---\nBody")
        file.frontMatter.tags = []
        #expect(file.contents == "Body")
    }

    @Test func unterminatedFrontMatterIsBody() {
        let contents = "---\ntags: [a]\nBody"
        let file = MarkdownNoteFile(contents: contents)
        #expect(file.frontMatter.isEmpty)
        #expect(file.body == contents)
    }
}
