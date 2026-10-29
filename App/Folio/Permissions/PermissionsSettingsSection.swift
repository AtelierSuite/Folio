import Planner
import SwiftUI

struct PermissionsSettingsSection: View {
    @Environment(PermissionCenter.self) private var center

    var body: some View {
        Section {
            ForEach(center.availableKinds) { kind in
                PermissionStatusRow(kind: kind)
            }
        } header: {
            Text(String(localized: "Settings.Header", table: "Permissions"))
        } footer: {
            Text(String(localized: "Settings.Footer", table: "Permissions"))
        }
    }
}
