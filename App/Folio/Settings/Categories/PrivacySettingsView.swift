import SwiftUI

struct PrivacySettingsView: View {
    var body: some View {
        Form {
            PermissionsSettingsSection()
            LeaveBySettingsSection()
        }
        .settingsCategoryStyle(.privacy)
    }
}
