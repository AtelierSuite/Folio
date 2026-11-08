import AppIntents
import Planner
import SwiftUI
import WidgetKit

struct DailyNoteControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "DailyNoteControl") {
            ControlWidgetButton(action: OpenDailyNoteIntent()) {
                Label(String(localized: "Control.DailyNote", table: "IntentControls"), systemImage: "note.text")
            }
        }
        .displayName(LocalizedStringResource("Control.DailyNote", table: "IntentControls"))
        .description(LocalizedStringResource("Control.DailyNote.Description", table: "IntentControls"))
    }
}
