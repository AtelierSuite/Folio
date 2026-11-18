import SwiftUI

struct AlarmSettingsView: View {
    var body: some View {
        Form {
            AlarmSnoozeSection()
        }
        .settingsCategoryStyle(.alarms)
    }
}
