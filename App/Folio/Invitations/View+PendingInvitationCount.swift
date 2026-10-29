import Planner
import SwiftUI

extension View {
    func loadsPendingInvitationCount(into count: Binding<Int>, from store: CalendarStore) -> some View {
        task(id: store.contentRevision) {
            count.wrappedValue = await store.pendingInvitations().count
        }
    }
}
