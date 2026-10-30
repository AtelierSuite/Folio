import Planner
import SwiftUI

struct ArrivalAlertsAccessRows: View {
    let authorization: ArrivalAuthorization
    let isMonitoringAvailable: Bool

    var body: some View {
        if let message {
            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
            PermissionSettingsButton(kind: .location)
        } else if !isMonitoringAvailable {
            Text(String(localized: "Settings.Unavailable", table: "ArrivalAlerts"))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var message: String? {
        switch authorization {
        case .denied: String(localized: "Settings.Denied", table: "ArrivalAlerts")
        case .whenInUse: String(localized: "Settings.WhenInUse", table: "ArrivalAlerts")
        case .notDetermined, .always: nil
        }
    }
}
