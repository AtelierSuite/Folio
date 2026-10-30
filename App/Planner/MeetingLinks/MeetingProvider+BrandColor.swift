import SwiftUI

extension MeetingProvider {
    /// The provider's key brand color, for the most widely used services. Others keep the surrounding tint.
    public var brandColor: Color? {
        switch self {
        case .zoom: Color(red: 0x0B / 255, green: 0x5C / 255, blue: 0xFF / 255)
        case .googleMeet: Color(red: 0x00 / 255, green: 0x83 / 255, blue: 0x2D / 255)
        case .microsoftTeams: Color(red: 0x5B / 255, green: 0x5F / 255, blue: 0xC7 / 255)
        case .webex: Color(red: 0x00 / 255, green: 0x7A / 255, blue: 0xA3 / 255)
        case .faceTime: Color(red: 0x34 / 255, green: 0xC7 / 255, blue: 0x59 / 255)
        case .slack: Color(red: 0x61 / 255, green: 0x1F / 255, blue: 0x69 / 255)
        case .discord: Color(red: 0x58 / 255, green: 0x65 / 255, blue: 0xF2 / 255)
        default: nil
        }
    }
}

extension View {
    /// Tints with the provider's brand color when it has one, leaving any outer tint in place otherwise.
    @ViewBuilder
    func meetingProviderTint(_ provider: MeetingProvider) -> some View {
        if let brandColor = provider.brandColor {
            tint(brandColor)
        } else {
            self
        }
    }
}
