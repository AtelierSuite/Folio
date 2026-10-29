import Testing
@testable import Planner

struct MarkdownTextEditTests {
    @Test func wrapsAndUnwrapsSelection() {
        let bold = MarkdownTextEdit(text: "make bold now", selection: 5..<9).applying(.bold)
        #expect(bold == MarkdownTextEdit(text: "make **bold** now", selection: 7..<11))
        #expect(bold.applying(.bold) == MarkdownTextEdit(text: "make bold now", selection: 5..<9))
        let selectedMarkers = MarkdownTextEdit(text: "`code`", selection: 0..<6).applying(.inlineCode)
        #expect(selectedMarkers == MarkdownTextEdit(text: "code", selection: 0..<4))
    }

    @Test func insertsEmptyMarkersAtCursor() {
        let edit = MarkdownTextEdit(text: "ab", selection: 1..<1).applying(.strikethrough)
        #expect(edit == MarkdownTextEdit(text: "a~~~~b", selection: 3..<3))
    }

    @Test func insertsLinks() {
        let selected = MarkdownTextEdit(text: "see docs", selection: 4..<8).applying(.link)
        #expect(selected == MarkdownTextEdit(text: "see [docs](https://)", selection: 11..<19))
        let empty = MarkdownTextEdit(text: "", selection: 0..<0).applying(.link)
        #expect(empty == MarkdownTextEdit(text: "[](https://)", selection: 1..<1))
    }

    @Test func togglesListPrefixesAcrossLines() {
        let edit = MarkdownTextEdit(text: "one\ntwo\n\nthree", selection: 1..<8).applying(.numberedList)
        #expect(edit.text == "1. one\n2. two\n\nthree")
        let removed = MarkdownTextEdit(text: edit.text, selection: 0..<13).applying(.numberedList)
        #expect(removed.text == "one\ntwo\n\nthree")
    }

    @Test func switchesBetweenListKinds() {
        let task = MarkdownTextEdit(text: "- item", selection: 6..<6).applying(.taskList)
        #expect(task == MarkdownTextEdit(text: "- [ ] item", selection: 10..<10))
        #expect(task.applying(.bulletList).text == "- item")
        #expect(task.applying(.taskList).text == "item")
        #expect(MarkdownTextEdit(text: "quote", selection: 0..<0).applying(.blockQuote).text == "> quote")
    }

    @Test func cyclesHeadingLevels() {
        var edit = MarkdownTextEdit(text: "Title", selection: 5..<5)
        var results: [String] = []
        for _ in 0..<4 {
            edit = edit.applying(.heading)
            results.append(edit.text)
        }
        #expect(results == ["# Title", "## Title", "### Title", "Title"])
        #expect(edit.selection == 5..<5)
    }

    @Test func wrapsLinesInCodeBlock() {
        let edit = MarkdownTextEdit(text: "intro\nlet a = 1", selection: 8..<8).applying(.codeBlock)
        #expect(edit == MarkdownTextEdit(text: "intro\n```\nlet a = 1\n```", selection: 10..<19))
    }
}
