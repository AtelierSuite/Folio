import SwiftUI

struct LocationSettingsView: View {
    var body: some View {
        Form {
            EventLocationsSettingsSection()
        }
        .settingsCategoryStyle(.locations)
    }
}
