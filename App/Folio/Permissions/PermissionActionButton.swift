import Planner
import SwiftUI

struct PermissionActionButton: View {
    let kind: PermissionKind
    let status: PermissionStatus
    var requestTitle: String?

    var body: some View {
        if status.canRequest {
            PermissionRequestButton(kind: kind, title: requestTitle)
        } else if status.canBeFixedInSettings {
            PermissionSettingsButton(kind: kind)
        } else if status.mayHideMissingAccess {
            PermissionSettingsButton(kind: kind, title: String(localized: "Action.Manage", table: "Permissions"))
        }
    }
}
