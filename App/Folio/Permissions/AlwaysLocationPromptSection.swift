import Planner
import SwiftUI

/// The permission card for features that need location set to Always, which `PermissionPromptSection`
/// can't show because While Using already counts as allowed.
struct AlwaysLocationPromptSection: View {
    @Environment(\.openURL) private var openURL
    let authorization: ArrivalAuthorization
    var isMonitoringAvailable = true
    let table: String

    var body: some View {
        if authorization == .whenInUse {
            Section {
                PermissionPromptMessage(
                    message: String(localized: "Settings.WhenInUse", table: table), isRestricted: false
                )
                if let url = PermissionKind.location.appSettingsURL {
                    Button(String(localized: "Action.OpenSettings", table: "Permissions")) {
                        openURL(url)
                    }
                    .accessibilityIdentifier("PermissionPrompt.location.Always")
                }
            }
        } else if !isMonitoringAvailable {
            Section {
                PermissionPromptMessage(
                    message: String(localized: "Settings.Unavailable", table: table), isRestricted: false
                )
            }
        }
    }
}
