import SwiftUI

struct SearchAndPrivacySettingsView: View {
    var body: some View {
        Form {
            SearchSettingsSection()
            PermissionsSettingsSection()
        }
        .settingsCategoryStyle(.searchAndPrivacy)
    }
}
