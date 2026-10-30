import Planner
import SwiftUI

struct LocationAlertAccessRows: View {
    let authorization: ArrivalAuthorization
    var isMonitoringAvailable = true
    let table: String

    var body: some View {
        if let message {
            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
            PermissionSettingsButton(kind: .location)
        } else if !isMonitoringAvailable {
            Text(String(localized: "Settings.Unavailable", table: table))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var message: String? {
        switch authorization {
        case .denied: String(localized: "Settings.Denied", table: table)
        case .whenInUse: String(localized: "Settings.WhenInUse", table: table)
        case .notDetermined, .always: nil
        }
    }
}
