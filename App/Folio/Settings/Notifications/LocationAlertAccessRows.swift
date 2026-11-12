import Planner
import SwiftUI

struct LocationAlertAccessRows: View {
    let authorization: ArrivalAuthorization
    var isMonitoringAvailable = true
    let table: String

    var body: some View {
        if authorization == .whenInUse {
            Text(String(localized: "Settings.WhenInUse", table: table))
                .font(.footnote)
                .foregroundStyle(.secondary)
            PermissionSettingsButton(kind: .location)
        } else if !isMonitoringAvailable {
            Text(String(localized: "Settings.Unavailable", table: table))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
