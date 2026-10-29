import AppIntents
import Planner
import SwiftUI
import WidgetKit

struct JoinNextMeetingControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "JoinNextMeetingControl") {
            ControlWidgetButton(action: JoinNextMeetingIntent()) {
                Label(String(localized: "Control.JoinNextMeeting", table: "IntentControls"), systemImage: "video")
            }
        }
        .displayName(LocalizedStringResource("Control.JoinNextMeeting", table: "IntentControls"))
        .description(LocalizedStringResource("Control.JoinNextMeeting.Description", table: "IntentControls"))
    }
}
