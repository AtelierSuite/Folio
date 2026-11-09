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
            Text(footer)
        }
        .task {
            await wakeUpAlarms.replan()
        }
    }

    private var footer: String {
        guard wakeUpAlarms.isSupported else { return String(localized: "Unsupported", table: "WakeUpAlarms") }
        let footer = String(localized: "Footer", table: "WakeUpAlarms")
        guard wakeUpAlarms.isEnabled && wakeUpAlarms.addsTravelTime else { return footer }
        return footer + " " + String(localized: "TravelTime.Footer", table: "WakeUpAlarms")
    }
}
