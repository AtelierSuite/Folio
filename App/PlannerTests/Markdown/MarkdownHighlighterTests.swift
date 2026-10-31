import Foundation
import Testing
@testable import Planner

struct MarkdownHighlighterTests {
    private func highlighted(_ text: String, as kind: MarkdownHighlight.Kind) -> [String] {
        MarkdownHighlighter.highlights(in: text)
            .filter { $0.kind == kind }
            .map { (text as NSString).substring(with: $0.range) }
    }

    @Test func highlightsHeadingsAndTheirMarkers() {
        let text = "## Plans\nbody"
        #expect(highlighted(text, as: .heading(level: 2)) == ["## Plans"])
        #expect(highlighted(text, as: .syntax) == ["## "])
        #expect(highlighted("#hashtag", as: .heading(level: 1)).isEmpty)
    }

    @Test func highlightsInlineStyles() {
        let text = "a **bold** _it_ *em* ~~gone~~ `co*de*`"
        #expect(highlighted(text, as: .bold) == ["**bold**"])
        #expect(highlighted(text, as: .italic) == ["_it_", "*em*"])
        #expect(highlighted(text, as: .strikethrough) == ["~~gone~~"])
        #expect(highlighted(text, as: .inlineCode) == ["`co*de*`"])
        #expect(highlighted("snake_case_name", as: .italic).isEmpty)
    }

    @Test func highlightsLinksWithDimmedDestination() {
        let text = "see [docs](https://example.com)"
        #expect(highlighted(text, as: .link) == ["docs"])
        #expect(highlighted(text, as: .syntax) == ["[", "](https://example.com)"])
    }

    @Test func highlightsHorizontalRules() {
        #expect(highlighted("a\n---\nb", as: .horizontalRule) == ["---"])
        #expect(highlighted("a\n---\nb", as: .syntax).isEmpty)
    }

    @Test func highlightsListsTasksAndQuotes() {
        let text = "- [x] done\n- [ ] todo\n1. first\n> quoted"
        #expect(highlighted(text, as: .listMarker) == ["- [x] ", "- [ ] ", "1. "])
        #expect(highlighted(text, as: .completedTask) == ["done"])
        #expect(highlighted(text, as: .task(isChecked: true)) == ["- [x] "])
        #expect(highlighted(text, as: .task(isChecked: false)) == ["- [ ] "])
        #expect(highlighted(text + "\n* plain", as: .bullet) == ["* "])
        #expect(highlighted(text, as: .blockQuote) == ["> quoted"])
    }

    @Test func skipsInlineStylesInsideCodeBlocks() {
        let text = "```\n**not bold**\n```\n**bold**"
        #expect(highlighted(text, as: .codeBlock) == ["```\n**not bold**\n```"])
        #expect(highlighted(text, as: .bold) == ["**bold**"])
    }

    @Test func highlightsFrontMatter() {
        let text = "---\nevent: abc\n---\n# Title"
        #expect(highlighted(text, as: .frontMatter) == ["---\nevent: abc\n---"])
        #expect(highlighted(text, as: .heading(level: 1)) == ["# Title"])
    }

    @Test func usesUTF16Ranges() {
        let text = "😀 **太字**"
        #expect(highlighted(text, as: .bold) == ["**太字**"])
    }
}
