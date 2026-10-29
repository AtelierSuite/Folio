import Foundation
import Testing
@testable import Planner

struct MeetingLinkTests {
    @Test func prefersTheEventURL() {
        let url = URL(string: "https://zoom.example.com/j/1")
        #expect(MeetingLink.joinURL(in: ["https://other.example.com"], url: url) == url)
    }

    @Test func findsTheFirstWebLinkInText() {
        let joinURL = MeetingLink.joinURL(in: [nil, "Room 4", "Dial in: https://meet.example.com/xyz or call"])
        #expect(joinURL == URL(string: "https://meet.example.com/xyz"))
    }

    @Test func ignoresLinksWithoutAWebScheme() {
        #expect(MeetingLink.joinURL(in: ["see example.com", "mail someone@example.com"]) == nil)
        #expect(MeetingLink.joinURL(in: [], url: URL(string: "mailto:someone@example.com")) == nil)
    }
}
