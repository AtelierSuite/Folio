import SwiftUI

struct NotificationDeniedSection: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        Section {
            Text(String(localized: "Denied", table: "Notifications"))
                .foregroundStyle(.secondary)
            if let settingsURL = NotificationSettingsURL.current {
                Button(String(localized: "Denied.OpenSettings", table: "Notifications")) {
                    openURL(settingsURL)
                }
            }
        }
    }
}
