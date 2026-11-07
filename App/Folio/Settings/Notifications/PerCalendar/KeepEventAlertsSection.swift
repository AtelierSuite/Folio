import Planner
import SwiftUI

struct KeepEventAlertsSection: View {
    @State private var keepsEventAlerts = NotificationSettings().keepsEventAlerts

    var body: some View {
        Section {
            Toggle(String(localized: "KeepAlerts.Toggle", table: "Notifications"), isOn: $keepsEventAlerts)
                .accessibilityIdentifier("KeepEventAlertsToggle")
        } footer: {
            Text(String(localized: "KeepAlerts.Footer", table: "Notifications"))
        }
        .onChange(of: keepsEventAlerts) { _, newValue in
            NotificationSettings().keepsEventAlerts = newValue
        }
    }
}
