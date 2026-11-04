import Planner
import SwiftUI

extension View {
    func loadsInvitationCounts(into counts: Binding<InvitationCounts>, from store: CalendarStore) -> some View {
        task(id: store.contentRevision) {
            counts.wrappedValue = await store.invitationCounts()
        }
    }
}
