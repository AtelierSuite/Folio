import Foundation
import Testing
@testable import Planner

struct MeetingJoinDeepLinkTests {
    @Test func roundTripsAMeetingLink() throws {
        let meetingURL = try #require(URL(string: "https://acme.zoom.us/j/81234567890?pwd=a%2Bb&uname=Jane"))
        let link = MeetingLink(provider: .zoom, url: meetingURL)
        let deepLink = try #require(link.joinDeepLink)
        #expect(deepLink.scheme == "folio")
        #expect(deepLink.host() == "join")
        #expect(MeetingJoinDeepLink.meetingLink(from: deepLink) == link)
    }

    @Test func refusesLinksThatAreNotMeetings() throws {
        let deepLink = try #require(URL(string: "folio://join?url=https%3A%2F%2Fexample.com%2Fphish"))
        #expect(MeetingJoinDeepLink.meetingLink(from: deepLink) == nil)
    }

    @Test func ignoresOtherFolioLinks() throws {
        let noteLink = try #require(URL(string: "folio://note/Inbox.md"))
        #expect(MeetingJoinDeepLink.meetingLink(from: noteLink) == nil)
    }
}
