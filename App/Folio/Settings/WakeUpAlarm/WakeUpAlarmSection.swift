import Planner
import SwiftUI

struct WakeUpAlarmSection: View {
    @Environment(WakeUpAlarmCenter.self) private var wakeUpAlarms

    var body: some View {
        Section {
            Toggle(String(localized: "Toggle", table: "WakeUpAlarms"), isOn: Binding(
                get: { wakeUpAlarms.isEnabled },
                set: { newValue in Task { await wakeUpAlarms.setEnabled(newValue) } }
            ))
            .disabled(!wakeUpAlarms.isSupported)
            .accessibilityIdentifier("WakeUpAlarmToggle")
            if wakeUpAlarms.isEnabled {
                if wakeUpAlarms.authorization == .denied {
                    WakeUpAlarmDeniedRows()
                } else {
                    WakeUpAlarmOptionRows()
                }
            }
        } header: {
            Text(String(localized: "Section", table: "WakeUpAlarms"))
        } footer: {
            Text(wakeUpAlarms.isSupported
                 ? String(localized: "Footer", table: "WakeUpAlarms")
                 : String(localized: "Unsupported", table: "WakeUpAlarms"))
        }
        .task {
            await wakeUpAlarms.replan()
        }
    }
}
