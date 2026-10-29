import SwiftUI

struct NotificationPoliciesSection: View {
    var body: some View {
        Section(String(localized: "About.Section", table: "Notifications")) {
            policy("About.AlertTimes")
            policy("About.Limit")
            policy("About.Stale")
        }
    }

    private func policy(_ key: String.LocalizationValue) -> some View {
        Text(String(localized: key, table: "Notifications"))
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}
