import AppIntents
import Planner
import SwiftUI
import WidgetKit

struct OpenTodayControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "OpenTodayControl") {
            ControlWidgetButton(action: OpenTodayIntent()) {
                Label(String(localized: "Control.OpenToday", table: "IntentControls"), systemImage: "calendar")
            }
        }
        .displayName(LocalizedStringResource("Control.OpenToday", table: "IntentControls"))
        .description(LocalizedStringResource("Control.OpenToday.Description", table: "IntentControls"))
    }
}
