import Planner
import SwiftUI

struct LinkedNotesSettingsSection: View {
    @AppStorage(LinkedNoteSettings.writesLinkToEventKey, store: AppGroup.userDefaults)
    private var writesLinkToEvent = false

    var body: some View {
        Section {
            Toggle(String(localized: "Settings.WritesLinkToEvent", table: "LinkedNotes"), isOn: $writesLinkToEvent)
                .accessibilityIdentifier("LinkedNotes.WritesLinkToEvent")
        } header: {
            Text(String(localized: "Settings.Header", table: "LinkedNotes"))
        } footer: {
            Text(String(localized: "Settings.Footer", table: "LinkedNotes"))
        }
    }
}
