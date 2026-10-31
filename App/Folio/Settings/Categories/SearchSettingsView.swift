import SwiftUI

struct SearchSettingsView: View {
    var body: some View {
        Form {
            SearchSettingsSection()
        }
        .settingsCategoryStyle(.search)
    }
}
