import Planner
import SwiftUI

struct InvitationsToolbarItem: ToolbarContent {
    @Environment(CalendarStore.self) private var store
    @State private var pendingCount = 0
    @State private var isPresented = false

    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button(String(localized: "Toolbar.Invitations", table: "Invitations"), systemImage: "envelope") {
                isPresented = true
            }
            .badge(pendingCount)
            .accessibilityIdentifier("InvitationsButton")
            .accessibilityValue(pendingCount > 0 ? "\(pendingCount)" : "")
            .sheet(isPresented: $isPresented) {
                InvitationsView()
            }
            .task(id: store.contentRevision) {
                pendingCount = await store.pendingInvitations().count
            }
        }
    }
}
