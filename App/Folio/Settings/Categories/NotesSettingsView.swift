import SwiftUI

struct NotesSettingsView: View {
    var body: some View {
        Form {
            NotesStorageSection()
            LinkedNotesSettingsSection()
        }
        .settingsCategoryStyle(.notes)
    }
}
