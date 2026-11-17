import Planner
import SwiftUI

struct WakeUpTravelTimeSection: View {
    @Environment(WakeUpAlarmCenter.self) private var wakeUpAlarms
    @Environment(PermissionCenter.self) private var permissionCenter

    var body: some View {
        if wakeUpAlarms.addsTravelTime {
            AlwaysLocationPromptSection(authorization: wakeUpAlarms.locationAuthorization, table: "WakeUpAlarms")
        }
        Section {
            Toggle(String(localized: "TravelTime", table: "WakeUpAlarms"), isOn: Binding(
                get: { wakeUpAlarms.addsTravelTime },
                set: { addsTravelTime in
                    Task {
                        guard await permissionCenter.allowsTurningOn(addsTravelTime, needing: .location) else { return }
                        await wakeUpAlarms.setAddsTravelTime(addsTravelTime)
                    }
                }
            ))
            .disabled(isMissingLocationAccess)
            .accessibilityIdentifier("WakeUpTravelTimeToggle")
            if wakeUpAlarms.addsTravelTime {
                TravelTransportPicker(selection: Binding(
                    get: { wakeUpAlarms.transport },
                    set: { transport in Task { await wakeUpAlarms.setTransport(transport) } }
                ), accessibilityIdentifier: "WakeUpTravelTransportPicker")
                .disabled(isMissingLocationAccess)
            }
        } header: {
            Text(String(localized: "Section.TravelTime", table: "WakeUpAlarms"))
        } footer: {
            Text(String(localized: "TravelTime.Footer", table: "WakeUpAlarms"))
        }
    }

    private var isMissingLocationAccess: Bool {
        permissionCenter.isBlocked(.location)
    }
}
