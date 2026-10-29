import Planner
import SwiftUI

struct EventDetailJoinSection: View {
    let link: MeetingLink

    var body: some View {
        Section {
            JoinMeetingButton(link: link, style: .prominent)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
        }
    }
}
