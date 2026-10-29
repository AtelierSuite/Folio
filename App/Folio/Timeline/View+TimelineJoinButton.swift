import Planner
import SwiftUI

extension View {
    /// Sits over the card's selection button rather than inside it, so a tap joins instead of selecting.
    func timelineJoinButton(_ link: MeetingLink?, isShown: Bool, color: Color) -> some View {
        overlay(alignment: .topTrailing) {
            if let link, isShown {
                JoinMeetingButton(link: link, style: .icon)
                    .tint(color)
                    .padding(TimelineMetrics.joinButtonInset)
            }
        }
    }
}
