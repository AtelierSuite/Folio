import Planner
import SwiftUI

struct EnergyLevelSettingsView: View {
    var body: some View {
        Form {
            PermissionPromptSection(
                kind: .health,
                message: String(localized: "Prompt.FocusLevel", table: "Permissions"),
                asksOnToggle: true
            )
            EnergyLevelSettingsSection()
        }
        .settingsCategoryStyle(.energyLevel)
    }
}
