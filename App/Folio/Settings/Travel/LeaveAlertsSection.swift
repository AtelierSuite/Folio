import Planner
import SwiftUI

struct LeaveAlertsSection: View {
    @Environment(LeaveAlertCenter.self) private var leaveAlerts
    @Environment(NotificationScheduler.self) private var scheduler
    @Environment(PermissionCenter.self) private var permissionCenter
    @Environment(\.platformCapabilities) private var capabilities

    var body: some View {
        if leaveAlerts.isSupported && leaveAlerts.isEnabled {
            AlwaysLocationPromptSection(authorization: leaveAlerts.authorization, table: "LeaveAlerts")
        }
        Section {
            Toggle(String(localized: "Settings.Toggle", table: "LeaveAlerts"), isOn: Binding(
                get: { leaveAlerts.isEnabled },
                set: { newValue in
                    Task {
                        guard await permissionCenter.allowsTurningOn(newValue, needing: .location) else { return }
                        await leaveAlerts.setEnabled(newValue)
                    }
                }
            ))
            .disabled(!leaveAlerts.isSupported || !scheduler.isEnabled || isMissingLocationAccess)
            .accessibilityIdentifier("LeaveAlertsToggle")
            if leaveAlerts.isSupported && leaveAlerts.isEnabled {
                TravelTransportPicker(selection: Binding(
                    get: { leaveAlerts.transport },
                    set: { newValue in Task { await leaveAlerts.setTransport(newValue) } }
                ), accessibilityIdentifier: "TravelTransportPicker")
                .disabled(isMissingLocationAccess)
                if capabilities.supports(.alarms) {
                    LeaveAlertStylePicker()
                    if leaveAlerts.ringsAsAlarm {
                        AlarmSoundPicker(
                            selection: leaveAlerts.alarmSound,
                            select: { sound in Task { await leaveAlerts.setAlarmSound(sound) } },
                            accessibilityIdentifier: "LeaveAlarmSoundPicker"
                        )
                    }
                }
            }
        } header: {
            Text(String(localized: "Settings.Section", table: "LeaveAlerts"))
        } footer: {
            Text(leaveAlerts.isSupported
                 ? String(localized: "Settings.Footer", table: "LeaveAlerts")
                 : String(localized: "Unsupported", table: "LeaveAlerts"))
        }
        .onChange(of: permissionCenter.status(of: .location), initial: true) {
            leaveAlerts.refreshAuthorization()
        }
    }

    private var isMissingLocationAccess: Bool {
        permissionCenter.isBlocked(.location)
    }
}
