import Foundation

extension MeetingLinkRule {
    static let customSchemes: [String: MeetingProvider] = [
        "zoommtg": .zoom,
        "zoomus": .zoom,
        "msteams": .microsoftTeams,
        "facetime": .faceTime,
        "facetime-audio": .faceTime
    ]

    static let known: [MeetingLinkRule] = [
        MeetingLinkRule(
            provider: .zoom,
            domains: ["zoom.us", "zoom.com", "zoomgov.com", "zoom.com.cn"],
            path: .prefixes(["/j/", "/my/", "/s/", "/w/", "/wc/", "/meeting/", "/join"])
        ),
        MeetingLinkRule(provider: .googleMeet, domains: ["meet.google.com"], path: .nonEmpty),
        MeetingLinkRule(
            provider: .microsoftTeams,
            domains: ["teams.microsoft.com", "teams.live.com", "teams.microsoft.us"],
            path: .contains(["meetup-join", "/meet/"])
        ),
        MeetingLinkRule(
            provider: .webex,
            domains: ["webex.com", "webex.com.cn"],
            path: .contains(["/meet/", "j.php", "/join/", "/wbxmjs/", "/webappng/"])
        ),
        MeetingLinkRule(provider: .faceTime, domains: ["facetime.apple.com"], path: .prefixes(["/join"])),
        MeetingLinkRule(provider: .slack, domains: ["slack.com"], path: .contains(["/huddle/"])),
        MeetingLinkRule(provider: .around, domains: ["around.co"], path: .prefixes(["/r/"])),
        MeetingLinkRule(provider: .whereby, domains: ["whereby.com"], path: .nonEmpty),
        MeetingLinkRule(provider: .goTo, domains: ["gotomeeting.com"], path: .prefixes(["/join/"])),
        MeetingLinkRule(provider: .goTo, domains: ["meet.goto.com", "gotomeet.me"], path: .nonEmpty),
        MeetingLinkRule(provider: .goTo, domains: ["app.goto.com"], path: .prefixes(["/meeting/"])),
        MeetingLinkRule(provider: .blueJeans, domains: ["bluejeans.com"], path: .nonEmpty),
        MeetingLinkRule(provider: .chime, domains: ["chime.aws"], path: .nonEmpty),
        MeetingLinkRule(provider: .jitsi, domains: ["meet.jit.si", "8x8.vc"], path: .nonEmpty),
        MeetingLinkRule(provider: .skype, domains: ["join.skype.com"], path: .nonEmpty),
        MeetingLinkRule(provider: .discord, domains: ["discord.gg"], path: .nonEmpty),
        MeetingLinkRule(
            provider: .discord, domains: ["discord.com", "discordapp.com"], path: .prefixes(["/invite/", "/channels/"])
        ),
        MeetingLinkRule(provider: .tencentMeeting, domains: ["meeting.tencent.com"], path: .nonEmpty),
        MeetingLinkRule(provider: .voov, domains: ["voovmeeting.com"], path: .nonEmpty),
        MeetingLinkRule(provider: .lark, domains: ["vc.larksuite.com"], path: .prefixes(["/j/"])),
        MeetingLinkRule(provider: .feishu, domains: ["vc.feishu.cn"], path: .prefixes(["/j/"])),
        MeetingLinkRule(provider: .zhumu, domains: ["zhumu.me", "zhumu.com"], path: .prefixes(["/j/"])),
        MeetingLinkRule(provider: .ringCentral, domains: ["meetings.ringcentral.com"], path: .prefixes(["/j/"])),
        MeetingLinkRule(provider: .ringCentral, domains: ["v.ringcentral.com"], path: .prefixes(["/join/"])),
        MeetingLinkRule(provider: .dialpad, domains: ["meetings.dialpad.com"], path: .nonEmpty)
    ]

    static func provider(for url: URL) -> MeetingProvider? {
        guard let scheme = url.scheme?.lowercased() else { return nil }
        if let provider = customSchemes[scheme] {
            return provider
        }
        guard scheme == "https" || scheme == "http", let host = url.host(percentEncoded: false)?.lowercased() else {
            return nil
        }
        let path = url.path(percentEncoded: false).lowercased()
        return known.first { $0.matches(host: host, path: path) }?.provider
    }
}
