import SwiftUI

struct FlexTimeSettingsView: View {
    var body: some View {
        Form {
            FlexTimeDaysSection()
            FlexTimeSleepSection()
            FlexTimeTodaySection()
        }
        .settingsCategoryStyle(.flexTime)
    }
}
