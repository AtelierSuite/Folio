import AppIntents
import Planner
import SwiftUI
import WidgetKit

struct DirectionsToNextEventControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "DirectionsToNextEventControl") {
            ControlWidgetButton(action: DirectionsToNextEventIntent()) {
                Label(
                    String(localized: "Control.DirectionsToNextEvent", table: "IntentControls"),
                    systemImage: "arrow.triangle.turn.up.right.diamond"
                )
            }
        }
        .displayName(LocalizedStringResource("Control.DirectionsToNextEvent", table: "IntentControls"))
        .description(LocalizedStringResource("Control.DirectionsToNextEvent.Description", table: "IntentControls"))
    }
}
