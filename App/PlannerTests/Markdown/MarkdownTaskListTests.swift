import Testing
@testable import Planner

struct MarkdownTaskListTests {
    @Test func togglesUncheckedAndCheckedTasks() {
        let contents = "# Tasks\n- [ ] One\n- [x] Two"
        #expect(MarkdownTaskList.togglingTask(atLine: 2, in: contents) == "# Tasks\n- [x] One\n- [x] Two")
        #expect(MarkdownTaskList.togglingTask(atLine: 3, in: contents) == "# Tasks\n- [ ] One\n- [ ] Two")
    }

    @Test func togglesNestedOrderedAndQuotedTasks() {
        #expect(MarkdownTaskList.togglingTask(atLine: 1, in: "    1. [ ] Nested") == "    1. [x] Nested")
        #expect(MarkdownTaskList.togglingTask(atLine: 1, in: "> * [X] Quoted") == "> * [ ] Quoted")
    }

    @Test func leavesOtherLinesUntouched() {
        let contents = "- Plain [ ] item\n[ ] not a task"
        #expect(MarkdownTaskList.togglingTask(atLine: 1, in: contents) == contents)
        #expect(MarkdownTaskList.togglingTask(atLine: 2, in: contents) == contents)
        #expect(MarkdownTaskList.togglingTask(atLine: 9, in: contents) == contents)
    }

    @Test func togglesTheLineReportedByTheParser() throws {
        let contents = "---\ntags: [a]\n---\nText\n\n- [ ] Task"
        guard case .list(let list) = try #require(MarkdownDocument(parsing: contents).blocks.last),
              let line = list.items.first?.sourceLine else {
            Issue.record("Expected a list")
            return
        }
        #expect(MarkdownTaskList.togglingTask(atLine: line, in: contents).hasSuffix("- [x] Task"))
    }
}
