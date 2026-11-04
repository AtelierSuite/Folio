import Planner
import SwiftUI

struct HiddenInvitationsView: View {
    @Environment(CalendarStore.self) private var store
    @State private var invitations: [CalendarEvent]?

    var body: some View {
        content
            .task(id: store.contentRevision) {
                invitations = await store.hiddenInvitations()
            }
    }

    @ViewBuilder
    private var content: some View {
        if let invitations, invitations.isEmpty {
            ContentUnavailableView(
                String(localized: "Hidden.Empty.Title", table: "Invitations"),
                systemImage: "eye",
                description: Text(String(localized: "Hidden.Empty.Description", table: "Invitations"))
            )
        } else {
            List(invitations ?? []) { event in
                HStack {
                    InvitationRow(event: event)
                    Button(String(localized: "Hidden.Show", table: "Invitations")) {
                        store.setHidden(false, invitation: event)
                    }
                    .buttonStyle(.borderless)
                    .accessibilityIdentifier("ShowInvitationButton")
                }
            }
            .overlay {
                if invitations == nil {
                    ProgressView()
                }
            }
        }
    }
}
