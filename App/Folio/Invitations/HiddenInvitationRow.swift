import Planner
import SwiftUI

struct HiddenInvitationRow: View {
    @Environment(CalendarStore.self) private var store
    let event: CalendarEvent

    var body: some View {
        HStack {
            InvitationRow(event: event)
            Button(String(localized: "Hidden.Show", table: "Invitations")) {
                store.setHidden(false, invitation: event)
            }
            .buttonStyle(.borderless)
            .accessibilityIdentifier("ShowInvitationButton")
        }
    }
}
