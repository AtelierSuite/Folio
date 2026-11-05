import SwiftUI

struct MedicationSettingsView: View {
    var body: some View {
        Form {
            MedicationSettingsSection()
            MedicationSharedListSection()
        }
        .settingsCategoryStyle(.medications)
    }
}
