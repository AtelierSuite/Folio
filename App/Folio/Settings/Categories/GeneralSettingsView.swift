import Planner
import SwiftUI

struct GeneralSettingsView: View {
    @Environment(\.platformCapabilities) private var capabilities

    var body: some View {
        Form {
            EventTapSettingsSection()
            TimelineSettingsSection()
            DragSettingsSection()
            MonthSettingsSection()
            if capabilities.supports(.menuBarExtra) {
                MenuBarSettingsSection()
            }
        }
        .settingsCategoryStyle(.general)
    }
}
