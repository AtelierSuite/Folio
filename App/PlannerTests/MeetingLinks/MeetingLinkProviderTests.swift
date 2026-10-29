import Foundation
import Testing
@testable import Planner

struct MeetingLinkProviderTests {
    private static let samples: [(String, MeetingProvider)] = [
        ("https://zoom.us/j/81234567890?pwd=aBcDeFgHiJkLmNoPqRsTuV.1", .zoom),
        ("https://us02web.zoom.us/j/81234567890?pwd=abc", .zoom),
        ("https://acme.zoom.us/my/jane.doe", .zoom),
        ("https://zoom.us/s/81234567890", .zoom),
        ("https://acme.zoomgov.com/j/1601234567", .zoom),
        ("https://app.zoom.us/wc/join/81234567890", .zoom),
        ("zoommtg://zoom.us/join?confno=81234567890&pwd=abc", .zoom),
        ("https://meet.google.com/abc-defg-hij", .googleMeet),
        ("https://meet.google.com/abc-defg-hij?authuser=1&hs=122", .googleMeet),
        (
            "https://teams.microsoft.com/l/meetup-join/19%3ameeting_NzQ5YTk2%40thread.v2/0"
                + "?context=%7b%22Tid%22%3a%2272f988bf%22%2c%22Oid%22%3a%22d1e2%22%7d",
            .microsoftTeams
        ),
        ("https://teams.microsoft.com/meet/2345678901234?p=AbCdEfGh", .microsoftTeams),
        ("https://teams.live.com/meet/9876543210123?p=XyZ", .microsoftTeams),
        ("https://gov.teams.microsoft.us/l/meetup-join/19%3ameeting_abc%40thread.v2/0", .microsoftTeams),
        ("msteams://teams.microsoft.com/l/meetup-join/19%3ameeting_abc%40thread.v2/0", .microsoftTeams),
        ("https://acme.webex.com/meet/jane.doe", .webex),
        ("https://acme.webex.com/acme/j.php?MTID=m1234567890abcdef", .webex),
        ("https://facetime.apple.com/join#v=1&p=AbCdEfGh&k=XyZ", .faceTime),
        ("facetime://jane@example.com", .faceTime),
        ("https://app.slack.com/huddle/T01234567/C01234567", .slack),
        ("https://around.co/r/acme-standup", .around),
        ("https://whereby.com/acme-standup", .whereby),
        ("https://global.gotomeeting.com/join/123456789", .goTo),
        ("https://meet.goto.com/123456789", .goTo),
        ("https://bluejeans.com/123456789/0123", .blueJeans),
        ("https://chime.aws/1234567890", .chime),
        ("https://app.chime.aws/meetings/1234567890", .chime),
        ("https://meet.jit.si/AcmeWeeklySync", .jitsi),
        ("https://8x8.vc/acme/standup", .jitsi),
        ("https://join.skype.com/AbCdEfGhIjKl", .skype),
        ("https://discord.gg/abcdef", .discord),
        ("https://discord.com/channels/123456789/987654321", .discord),
        ("https://meeting.tencent.com/dm/AbCdEfGh", .tencentMeeting),
        ("https://voovmeeting.com/dm/AbCdEfGh", .voov),
        ("https://vc.larksuite.com/j/123456789", .lark),
        ("https://vc.feishu.cn/j/123456789", .feishu),
        ("https://zhumu.me/j/123456789", .zhumu),
        ("https://meetings.ringcentral.com/j/1234567890", .ringCentral),
        ("https://v.ringcentral.com/join/123456789", .ringCentral),
        ("https://meetings.dialpad.com/acme-standup", .dialpad)
    ]

    @Test(arguments: samples)
    func recognizesProvider(link: String, provider: MeetingProvider) throws {
        let url = try #require(URL(string: link))
        #expect(MeetingLinkDetector.link(for: url) == MeetingLink(provider: provider, url: url))
    }

    @Test(arguments: [
        "https://zoom.us/pricing",
        "https://zoom.us",
        "https://www.google.com/calendar/event?eid=abc",
        "https://meet.google.com/",
        "https://teams.microsoft.com/v2/",
        "https://www.webex.com/pricing/index.html",
        "https://slack.com/intl/en-gb/",
        "https://discord.com/download",
        "https://example.com/j/123",
        "https://notzoom.us/j/123",
        "https://zoom.us.example.com/j/123",
        "mailto:jane@example.com",
        "tel:+15551234567"
    ])
    func ignoresOtherLinks(link: String) throws {
        let url = try #require(URL(string: link))
        #expect(MeetingLinkDetector.link(for: url) == nil)
    }

    @Test func hostMatchingIgnoresCase() throws {
        let url = try #require(URL(string: "HTTPS://Meet.Google.COM/abc-defg-hij"))
        #expect(MeetingLinkDetector.link(for: url)?.provider == .googleMeet)
    }

    @Test func everyProviderHasANameAndIcon() {
        for provider in MeetingProvider.allCases {
            #expect(!provider.displayName.isEmpty)
            #expect(!provider.systemImage.isEmpty)
        }
    }
}
