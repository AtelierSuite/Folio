import Planner
import SwiftUI

struct SleepSettingsView: View {
    var body: some View {
        Form {
            PermissionPromptSection(
                kind: .health,
                message: String(localized: "Prompt.Sleep", table: "Permissions")
            )
            SleepSettingsSection()
        }
        .settingsCategoryStyle(.sleep)
    }
}
