import Foundation

public enum MeetingProvider: String, Sendable, Hashable, Codable, CaseIterable {
    case zoom
    case googleMeet
    case microsoftTeams
    case webex
    case faceTime
    case slack
    case around
    case whereby
    case goTo
    case blueJeans
    case chime
    case jitsi
    case skype
    case discord
    case tencentMeeting
    case voov
    case lark
    case feishu
    case zhumu
    case ringCentral
    case dialpad

    /// Brand names stay the same in every language.
    public var displayName: String {
        switch self {
        case .zoom: "Zoom"
        case .googleMeet: "Google Meet"
        case .microsoftTeams: "Microsoft Teams"
        case .webex: "Webex"
        case .faceTime: "FaceTime"
        case .slack: "Slack"
        case .around: "Around"
        case .whereby: "Whereby"
        case .goTo: "GoTo Meeting"
        case .blueJeans: "BlueJeans"
        case .chime: "Amazon Chime"
        case .jitsi: "Jitsi Meet"
        case .skype: "Skype"
        case .discord: "Discord"
        case .tencentMeeting: "Tencent Meeting"
        case .voov: "VooV Meeting"
        case .lark: "Lark"
        case .feishu: "Feishu"
        case .zhumu: "Zhumu"
        case .ringCentral: "RingCentral"
        case .dialpad: "Dialpad"
        }
    }

    public var systemImage: String {
        switch self {
        case .slack, .discord: "headphones"
        default: "video.fill"
        }
    }
}
