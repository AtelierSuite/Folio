import Planner
import SwiftUI

struct InvitationSettingsSection: View {
    @Environment(CalendarStore.self) private var store
    @State private var hiddenInvitationCount = 0

    var body: some View {
        Section {
            Toggle(
                String(localized: "Settings.HidesDeclined", table: "Invitations"),
                isOn: Binding(get: { store.hidesDeclinedEvents }, set: { store.setHidesDeclinedEvents($0) })
            )
            .accessibilityIdentifier("HideDeclinedEventsToggle")
            if hiddenInvitationCount > 0 {
                SettingsSheetRow(
                    title: hiddenInvitationsTitle,
                    value: hiddenInvitationCount.formatted(),
                    sheetTitle: hiddenInvitationsTitle
                ) {
                    HiddenInvitationsView()
                }
                .accessibilityIdentifier("HiddenInvitationsRow")
            }
        } header: {
            Text(String(localized: "Settings.Header", table: "Invitations"))
        } footer: {
            Text(String(localized: "Settings.Footer", table: "Invitations"))
        }
        .task(id: store.contentRevision) {
            hiddenInvitationCount = await store.hiddenInvitations().count
        }
    }

    private var hiddenInvitationsTitle: String {
        String(localized: "Hidden.Title", table: "Invitations")
    }
}
