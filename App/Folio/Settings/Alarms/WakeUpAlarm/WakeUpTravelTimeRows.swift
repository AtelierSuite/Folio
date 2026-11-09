import Planner
import SwiftUI

struct WakeUpTravelTimeRows: View {
    @Environment(WakeUpAlarmCenter.self) private var wakeUpAlarms
    @Environment(PermissionCenter.self) private var permissions

    var body: some View {
        let status = permissions.status(of: .location) ?? .notDetermined
        Toggle(String(localized: "TravelTime", table: "WakeUpAlarms"), isOn: addsTravelTime)
            .accessibilityIdentifier("WakeUpTravelTimeToggle")
        if wakeUpAlarms.addsTravelTime {
            TravelTransportPicker(selection: Binding(
                get: { wakeUpAlarms.transport },
                set: { transport in Task { await wakeUpAlarms.setTransport(transport) } }
            ), accessibilityIdentifier: "WakeUpTravelTransportPicker")
            if status.canBeFixedInSettings {
                Text(String(localized: "TravelTime.LocationDenied", table: "WakeUpAlarms"))
                    .foregroundStyle(.secondary)
                PermissionActionButton(kind: .location, status: status)
            }
        }
    }

    private var addsTravelTime: Binding<Bool> {
        Binding {
            wakeUpAlarms.addsTravelTime
        } set: { addsTravelTime in
            Task {
                await wakeUpAlarms.setAddsTravelTime(addsTravelTime)
                guard addsTravelTime, permissions.status(of: .location) == .notDetermined else { return }
                await permissions.request(.location)
                await wakeUpAlarms.replan()
            }
        }
    }
}
