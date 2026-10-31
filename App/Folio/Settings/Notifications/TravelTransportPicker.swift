import Planner
import SwiftUI

struct TravelTransportPicker: View {
    @Environment(LeaveAlertCenter.self) private var leaveAlerts

    var body: some View {
        Picker(String(localized: "Settings.Transport", table: "LeaveAlerts"), selection: Binding(
            get: { leaveAlerts.transport },
            set: { newValue in Task { await leaveAlerts.setTransport(newValue) } }
        )) {
            ForEach(TravelTransport.allCases) { transport in
                Text(name(of: transport)).tag(transport)
            }
        }
        .accessibilityIdentifier("TravelTransportPicker")
    }

    private func name(of transport: TravelTransport) -> String {
        switch transport {
        case .driving: String(localized: "Transport.Driving", table: "LeaveAlerts")
        case .walking: String(localized: "Transport.Walking", table: "LeaveAlerts")
        case .transit: String(localized: "Transport.Transit", table: "LeaveAlerts")
        }
    }
}
