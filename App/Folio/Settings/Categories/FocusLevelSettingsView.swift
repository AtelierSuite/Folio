import Planner
import SwiftUI

struct FocusLevelSettingsView: View {
    var body: some View {
        Form {
            PermissionPromptSection(
                kind: .health,
                message: String(localized: "Prompt.FocusLevel", table: "Permissions"),
                asksOnToggle: true
            )
            FocusLevelSettingsSection()
        }
        .settingsCategoryStyle(.focusLevel)
    }
}
