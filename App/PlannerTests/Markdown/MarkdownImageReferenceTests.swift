import Foundation
import Testing
@testable import Planner

struct MarkdownImageReferenceTests {
    @Test func findsImagesOutsideCode() {
        let text = "![Cat](assets/cat.png)\n`![No](skip.png)`\n![Dog](dog%20one.jpg \"Title\")"
        let references = MarkdownImageReference.references(in: text)
        #expect(references.map(\.altText) == ["Cat", "Dog"])
        #expect(references.map(\.source) == ["assets/cat.png", "dog%20one.jpg"])
        #expect((text as NSString).substring(with: references[1].range) == "![Dog](dog%20one.jpg \"Title\")")
    }

    @Test func ignoresPlainLinks() {
        #expect(MarkdownImageReference.references(in: "[Cat](cat.png)").isEmpty)
    }
}
