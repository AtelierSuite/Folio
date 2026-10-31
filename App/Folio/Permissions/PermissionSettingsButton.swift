import Planner
import SwiftUI

struct PermissionSettingsButton: View {
    @Environment(\.openURL) private var openURL
    let kind: PermissionKind
    var title = String(localized: "Action.OpenSettings", table: "Permissions")

    var body: some View {
        if let url = kind.settingsURL {
            Button(title) {
                openURL(url)
            }
        }
    }
}
