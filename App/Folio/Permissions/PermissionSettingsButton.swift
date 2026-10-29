import Planner
import SwiftUI

struct PermissionSettingsButton: View {
    @Environment(\.openURL) private var openURL
    let kind: PermissionKind

    var body: some View {
        if let url = kind.settingsURL {
            Button(String(localized: "Action.OpenSettings", table: "Permissions")) {
                openURL(url)
            }
        }
    }
}
