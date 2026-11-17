import Planner
import SwiftUI

struct WakeUpAlarmSection: View {
    @Environment(WakeUpAlarmCenter.self) private var wakeUpAlarms
    @Environment(PermissionCenter.self) private var permissionCenter

    var body: some View {
        Section {
            Toggle(String(localized: "Toggle", table: "WakeUpAlarms"), isOn: Binding(
                get: { wakeUpAlarms.isEnabled },
                set: { newValue in
                    Task {
                        guard await permissionCenter.allowsTurningOn(newValue, needing: .alarms) else { return }
                        await wakeUpAlarms.setEnabled(newValue)
                    }
                }
            ))
            .disabled(!wakeUpAlarms.isSupported)
            .accessibilityIdentifier("WakeUpAlarmToggle")
            if wakeUpAlarms.isEnabled {
                WakeUpCalendarsLink()
                WakeUpLeadTimePicker()
                AlarmSoundPicker(
                    selection: wakeUpAlarms.sound,
                    select: { sound in Task { await wakeUpAlarms.setSound(sound) } },
                    accessibilityIdentifier: "WakeUpAlarmSoundPicker"
                )
            }
        } header: {
            Text(String(localized: "Section", table: "WakeUpAlarms"))
        } footer: {
            Text(footer)
        }
        .disabled(permissionCenter.isBlocked(.alarms))
        if wakeUpAlarms.isEnabled {
            WakeUpTimingSection()
                .disabled(permissionCenter.isBlocked(.alarms))
            PermissionPromptSection(
                kind: .location,
                message: String(localized: "Prompt.WakeUpTravelTime", table: "Permissions"),
                asksOnToggle: true
            )
            WakeUpTravelTimeSection()
                .disabled(permissionCenter.isBlocked(.alarms))
        }
    }

    private var footer: String {
        guard wakeUpAlarms.isSupported else { return String(localized: "Unsupported", table: "WakeUpAlarms") }
        return String(localized: "Footer", table: "WakeUpAlarms")
    }
}
