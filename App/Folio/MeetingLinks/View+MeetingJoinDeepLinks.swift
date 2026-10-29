import Planner
import SwiftUI

extension View {
    /// Widgets can only open Folio, so they join meetings through `folio://join`.
    func opensMeetingJoinDeepLinks() -> some View {
        modifier(MeetingJoinDeepLinkModifier())
    }
}

private struct MeetingJoinDeepLinkModifier: ViewModifier {
    @Environment(\.openURL) private var openURL

    func body(content: Content) -> some View {
        content.onOpenURL { url in
            if let link = MeetingJoinDeepLink.meetingLink(from: url) {
                openURL(link.url)
            }
        }
    }
}
