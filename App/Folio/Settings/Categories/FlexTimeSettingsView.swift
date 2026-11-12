import Planner
import SwiftUI

struct FlexTimeSettingsView: View {
    var body: some View {
        Form {
            PermissionPromptSection(
                kind: .health,
                message: String(localized: "Prompt.FlexTime", table: "Permissions"),
                asksOnToggle: true
            )
            FlexTimeDaysSection()
            FlexTimeSleepSection()
            FlexTimeTodaySection()
        }
        .settingsCategoryStyle(.flexTime)
    }
}
