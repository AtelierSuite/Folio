import Planner
import SwiftUI

struct WakeUpTravelTimeRows: View {
    @Environment(WakeUpAlarmCenter.self) private var wakeUpAlarms

    var body: some View {
        Toggle(String(localized: "TravelTime", table: "WakeUpAlarms"), isOn: Binding(
            get: { wakeUpAlarms.addsTravelTime },
            set: { addsTravelTime in Task { await wakeUpAlarms.setAddsTravelTime(addsTravelTime) } }
        ))
        .accessibilityIdentifier("WakeUpTravelTimeToggle")
        if wakeUpAlarms.addsTravelTime {
            TravelTransportPicker(selection: Binding(
                get: { wakeUpAlarms.transport },
                set: { transport in Task { await wakeUpAlarms.setTransport(transport) } }
            ), accessibilityIdentifier: "WakeUpTravelTransportPicker")
            LocationAlertAccessRows(authorization: wakeUpAlarms.locationAuthorization, table: "WakeUpAlarms")
        }
    }
}
