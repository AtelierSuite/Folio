import Planner
import SwiftUI

struct WakeUpSnoozePicker: View {
    @Environment(WakeUpAlarmCenter.self) private var wakeUpAlarms

    var body: some View {
        AlarmSnoozeOverridePicker(minutes: Binding(
            get: { wakeUpAlarms.snoozeMinutes },
            set: { newValue in Task { await wakeUpAlarms.setSnoozeMinutes(newValue) } }
        ))
        .accessibilityIdentifier("WakeUpSnoozePicker")
    }
}
