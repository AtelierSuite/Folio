import SwiftUI

/// Uses `Link` so it also works where buttons can't run code: widgets pass `opensThroughApp` to go through Folio.
public struct JoinMeetingButton: View {
    let link: MeetingLink
    let style: JoinMeetingButtonStyle
    let opensThroughApp: Bool

    public init(link: MeetingLink, style: JoinMeetingButtonStyle = .menu, opensThroughApp: Bool = false) {
        self.link = link
        self.style = style
        self.opensThroughApp = opensThroughApp
    }

    private var destination: URL {
        opensThroughApp ? (link.joinDeepLink ?? link.url) : link.url
    }

    private var title: String {
        link.provider.joinTitle
    }

    public var body: some View {
        Group {
            switch style {
            case .prominent:
                Link(destination: destination) {
                    Label(title, systemImage: link.provider.systemImage)
                        .labelStyle(.titleAndIcon)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            case .capsule:
                Link(destination: destination) {
                    HStack(spacing: 4) {
                        Image(systemName: link.provider.systemImage)
                        Text(String(localized: "Join", table: "MeetingLinks", bundle: #bundle))
                    }
                    .font(.caption.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .controlSize(.small)
            case .icon:
                Link(destination: destination) {
                    JoinMeetingIcon(systemImage: link.provider.systemImage)
                }
                .buttonStyle(.plain)
            case .menu:
                Link(destination: destination) {
                    Label(title, systemImage: link.provider.systemImage)
                }
            }
        }
        .meetingProviderTint(link.provider)
        .accessibilityLabel(title)
        .accessibilityIdentifier("JoinMeeting")
    }
}
