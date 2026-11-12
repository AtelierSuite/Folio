import Planner
import SwiftUI

struct MedicationSettingsView: View {
    var body: some View {
        Form {
            NotificationPermissionPromptSection(
                message: String(localized: "Prompt.MedicationReminders", table: "Permissions")
            )
            MedicationSettingsSection()
            MedicationSharedListSection()
        }
        .settingsCategoryStyle(.medications)
    }
}
