import Planner
import SwiftUI

extension View {
    /// Apple's event view, for answering an invitation from the quick actions.
    @ViewBuilder
    func eventResponseSheet(event: Binding<CalendarEvent?>) -> some View {
        #if os(iOS)
        sheet(item: event) { invitation in
            if let eventKitEvent = EventKitDataSource.shared.eventKitEvent(for: invitation.reference) {
                EventResponseSheet(event: eventKitEvent) { event.wrappedValue = nil }
                    .ignoresSafeArea()
            }
        }
        #else
        self
        #endif
    }
}
