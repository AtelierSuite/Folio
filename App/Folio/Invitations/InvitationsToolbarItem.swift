import Planner
import SwiftUI

struct InvitationsToolbarItem: ToolbarContent {
    let pendingCount: Int
    @State private var isPresented = false

    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button(String(localized: "Toolbar.Invitations", table: "Invitations"), systemImage: "envelope") {
                isPresented = true
            }
            .badge(pendingCount)
            .accessibilityIdentifier("InvitationsButton")
            .sheet(isPresented: $isPresented) {
                InvitationsView()
            }
        }
    }
}
