import Testing
@testable import Planner

struct MarkdownPlainTextTests {
    @Test func stripsMarkdownSyntaxAndFrontMatter() {
        let document = MarkdownDocument(parsing: """
        ---
        tags: [work]
        ---
        # Weekly **plan**

        - [ ] Call [Alex](https://example.com)
        - Ship `v2`

        > Quoted _text_

        | Day | Task |
        | --- | ---- |
        | Mon | Gym |

        <div>hidden</div>
        """)

        #expect(document.plainText == """
        Weekly plan
        Call Alex
        Ship v2
        Quoted text
        Day Task
        Mon Gym
        """)
    }
}
