import Foundation
import Testing
@testable import Planner

struct MarkdownURLResolverTests {
    private let baseURL = URL(filePath: "/Notes/Trip", directoryHint: .isDirectory)

    @Test func resolvesRelativeAssetPaths() {
        let expected = URL(filePath: "/Notes/Trip/assets/map.png")
        #expect(MarkdownURLResolver.url(for: "assets/map.png", relativeTo: baseURL) == expected)
        let encoded = MarkdownURLResolver.url(for: "assets/my%20map.png", relativeTo: baseURL)
        #expect(encoded?.path() == "/Notes/Trip/assets/my%20map.png")
        let unencoded = MarkdownURLResolver.url(for: "assets/my map.png", relativeTo: baseURL)
        #expect(unencoded?.path(percentEncoded: false) == "/Notes/Trip/assets/my map.png")
    }

    @Test func treatsBaseWithoutTrailingSlashAsDirectory() {
        let base = URL(filePath: "/Notes/Trip", directoryHint: .notDirectory)
        let expected = URL(filePath: "/Notes/Trip/assets/map.png")
        #expect(MarkdownURLResolver.url(for: "assets/map.png", relativeTo: base) == expected)
    }

    @Test func keepsAbsoluteURLs() {
        let url = URL(string: "https://example.com/image.png")
        #expect(MarkdownURLResolver.url(for: "https://example.com/image.png", relativeTo: baseURL) == url)
        #expect(MarkdownURLResolver.url(for: "  ", relativeTo: baseURL) == nil)
    }
}
