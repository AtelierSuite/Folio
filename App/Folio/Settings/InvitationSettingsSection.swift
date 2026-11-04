import Planner
import SwiftUI

struct InvitationSettingsSection: View {
    @Environment(CalendarStore.self) private var store

    var body: some View {
        Section {
            Toggle(
                String(localized: "Settings.HidesDeclined", table: "Invitations"),
                isOn: Binding(get: { store.hidesDeclinedEvents }, set: { store.setHidesDeclinedEvents($0) })
            )
            .accessibilityIdentifier("HideDeclinedEventsToggle")
        } header: {
            Text(String(localized: "Settings.Header", table: "Invitations"))
        } footer: {
            Text(String(localized: "Settings.Footer", table: "Invitations"))
        }
    }
}
