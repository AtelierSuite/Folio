import Planner
import SwiftUI

struct HiddenInvitationsView: View {
    @Environment(CalendarStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var invitations: [CalendarEvent]?

    var body: some View {
        List(invitations ?? []) { event in
            HiddenInvitationRow(event: event)
        }
        .overlay {
            if invitations == nil {
                ProgressView()
            }
        }
        .navigationTitle(String(localized: "Hidden.Title", table: "Invitations"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task(id: store.contentRevision) {
            let hiddenInvitations = await store.hiddenInvitations()
            invitations = hiddenInvitations
            if hiddenInvitations.isEmpty {
                dismiss()
            }
        }
    }
}
