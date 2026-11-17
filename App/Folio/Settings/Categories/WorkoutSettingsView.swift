import Planner
import SwiftUI

struct WorkoutSettingsView: View {
    var body: some View {
        Form {
            PermissionPromptSection(
                kind: .health,
                message: String(localized: "Prompt.Workouts", table: "Permissions"),
                asksOnToggle: true
            )
            WorkoutSettingsSection()
        }
        .settingsCategoryStyle(.workouts)
    }
}
