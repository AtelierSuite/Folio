import Foundation
import Testing
@testable import Planner

struct MeetingLinkUnwrapperTests {
    @Test func unwrapsOutlookSafeLinks() throws {
        let wrapped = try #require(URL(string:
            "https://nam12.safelinks.protection.outlook.com/?url=https%3A%2F%2Fus02web.zoom.us%2Fj%2F81234567890"
                + "%3Fpwd%3Dabc&data=05%7C01%7Cjane%40example.com%7C&sdata=AbC%3D&reserved=0"
        ))
        let link = MeetingLinkDetector.link(for: wrapped)
        #expect(link?.provider == .zoom)
        #expect(link?.url.absoluteString == "https://us02web.zoom.us/j/81234567890?pwd=abc")
    }

    @Test func unwrapsSafeLinksFoundInNotes() {
        let notes = """
            Click here to join the meeting<https://eur01.safelinks.protection.outlook.com/ap/t-59584e83/?url=\
            https%3A%2F%2Fteams.microsoft.com%2Fl%2Fmeetup-join%2F19%253ameeting_abc%2540thread.v2%2F0\
            &data=05%7C02&reserved=0>
            """
        let link = MeetingLinkDetector.firstLink(in: notes)
        #expect(link?.provider == .microsoftTeams)
        #expect(link?.url.host() == "teams.microsoft.com")
    }

    @Test func unwrapsGoogleRedirects() throws {
        let wrapped = try #require(URL(string:
            "https://www.google.com/url?q=https%3A%2F%2Fmeet.google.com%2Fabc-defg-hij&sa=D&source=calendar"
        ))
        #expect(MeetingLinkDetector.link(for: wrapped)?.url.absoluteString == "https://meet.google.com/abc-defg-hij")
    }

    @Test func unwrapsProofpointLinks() throws {
        let wrapped = try #require(URL(string:
            "https://urldefense.com/v3/__https://acme.zoom.us/j/81234567890__;!!AbC!dEf$"
        ))
        #expect(MeetingLinkDetector.link(for: wrapped)?.url.absoluteString == "https://acme.zoom.us/j/81234567890")
    }

    @Test func unwrapsNestedWrappers() throws {
        let inner = "https://www.google.com/url?q=https%3A%2F%2Fmeet.google.com%2Fabc-defg-hij"
        let encodedInner = try #require(inner.addingPercentEncoding(withAllowedCharacters: .alphanumerics))
        let wrapped = try #require(URL(string: "https://nam12.safelinks.protection.outlook.com/?url=\(encodedInner)"))
        #expect(MeetingLinkDetector.link(for: wrapped)?.provider == .googleMeet)
    }

    @Test func ignoresSafeLinksToOtherSites() throws {
        let wrapped = try #require(URL(string:
            "https://nam12.safelinks.protection.outlook.com/?url=https%3A%2F%2Fexample.com%2Fagenda&reserved=0"
        ))
        #expect(MeetingLinkDetector.link(for: wrapped) == nil)
    }

    @Test func ignoresWrappedNonWebSchemes() throws {
        let wrapped = try #require(URL(string:
            "https://nam12.safelinks.protection.outlook.com/?url=javascript%3Aalert(1)"
        ))
        #expect(MeetingLinkUnwrapper.unwrap(wrapped) == wrapped)
    }
}
