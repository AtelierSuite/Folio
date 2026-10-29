import Planner
import SwiftUI

struct ArrivalAlertsAccessRows: View {
    let authorization: ArrivalAuthorization

    var body: some View {
        if let message {
            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
            PermissionSettingsButton(kind: .location)
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
