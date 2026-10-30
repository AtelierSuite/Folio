import SwiftUI

struct GeneralSettingsView: View {
    var body: some View {
        Form {
            EventTapSettingsSection()
            TimelineSettingsSection()
            DragSettingsSection()
            MonthSettingsSection()
            WeatherSettingsSection()
        }
        .settingsCategoryStyle(.general)
    }
}
