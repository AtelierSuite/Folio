import SwiftUI

struct SleepSettingsView: View {
    var body: some View {
        Form {
            SleepSettingsSection()
        }
        .settingsCategoryStyle(.sleep)
    }
}
