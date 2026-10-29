import Testing
@testable import Planner

struct MarkdownDocumentTests {
    @Test func parsesHeadingsAndInlineFormatting() {
        let document = MarkdownDocument(parsing: "# Title\n\nSome **bold**, _italic_, ~~gone~~ and `code`.")
        #expect(document.blocks == [
            .heading(level: 1, content: [.text("Title")]),
            .paragraph([
                .text("Some "), .strong([.text("bold")]), .text(", "), .emphasis([.text("italic")]),
                .text(", "), .strikethrough([.text("gone")]), .text(" and "), .code("code"), .text(".")
            ])
        ])
    }

    @Test func parsesTaskListsWithSourceLines() throws {
        let document = MarkdownDocument(parsing: "Intro\n\n- [ ] Buy milk\n- [x] Call Sam\n- Plain")
        guard case .list(let list) = try #require(document.blocks.last) else {
            Issue.record("Expected a list")
            return
        }
        #expect(!list.isOrdered)
        #expect(list.items.map(\.checkbox) == [.unchecked, .checked, nil])
        #expect(list.items.map(\.sourceLine) == [3, 4, 5])
    }

    @Test func sourceLinesAccountForFrontMatter() throws {
        let document = MarkdownDocument(parsing: "---\ntags: [home]\n---\n- [ ] Task")
        guard case .list(let list) = try #require(document.blocks.first) else {
            Issue.record("Expected a list")
            return
        }
        #expect(list.items.first?.sourceLine == 4)
        #expect(document.frontMatter.tags == ["home"])
    }

    @Test func parsesOrderedListStart() throws {
        let document = MarkdownDocument(parsing: "3. Three\n4. Four")
        guard case .list(let list) = try #require(document.blocks.first) else {
            Issue.record("Expected a list")
            return
        }
        #expect(list.isOrdered)
        #expect(list.startIndex == 3)
        #expect(list.items.count == 2)
    }

    @Test func parsesTables() throws {
        let document = MarkdownDocument(parsing: "| Name | Qty | Price |\n|:-----|:---:|------:|\n| Tea | 2 | 4.50 |")
        guard case .table(let table) = try #require(document.blocks.first) else {
            Issue.record("Expected a table")
            return
        }
        #expect(table.columnAlignments == [.leading, .center, .trailing])
        #expect(table.header.map(\.plainText) == ["Name", "Qty", "Price"])
        #expect(table.rows.map { $0.map(\.plainText) } == [["Tea", "2", "4.50"]])
        #expect(table.columnCount == 3)
    }

    @Test func parsesCodeBlocksQuotesAndBreaks() {
        let document = MarkdownDocument(parsing: "```swift\nlet value = 1\n```\n\n> Quoted\n\n---")
        #expect(document.blocks == [
            .codeBlock(language: "swift", code: "let value = 1"),
            .blockQuote([.paragraph([.text("Quoted")])]),
            .thematicBreak
        ])
    }

    @Test func standaloneImagesBecomeImageBlocks() {
        let document = MarkdownDocument(parsing: "![A cat](assets/cat.png \"Cat\")\n\nSee [site](https://example.com).")
        #expect(document.blocks == [
            .image(MarkdownImage(source: "assets/cat.png", altText: "A cat", title: "Cat")),
            .paragraph([
                .text("See "), .link(destination: "https://example.com", content: [.text("site")]), .text(".")
            ])
        ])
    }

    @Test func keepsQuotesLiteral() {
        let document = MarkdownDocument(parsing: "\"Quoted\" -- text")
        #expect(document.blocks == [.paragraph([.text("\"Quoted\" -- text")])])
    }
}
