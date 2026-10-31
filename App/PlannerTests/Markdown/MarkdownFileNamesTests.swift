import Foundation
import Testing
@testable import Planner

struct MarkdownFileNamesTests {
    @Test func findsFileNamesInEveryKindOfReference() {
        let text = """
        ![Cat](assets/Cat.png) [Report](../assets/report%20final.pdf)
        ![[diagram.jpeg|300]] <img src="assets/photo.heic"> ![Spaced](<assets/my photo.png>)
        """
        let names = MarkdownFileNames.names(in: text)
        #expect(names.isSuperset(of: ["cat.png", "report final.pdf", "diagram.jpeg", "photo.heic", "my photo.png"]))
    }
}
