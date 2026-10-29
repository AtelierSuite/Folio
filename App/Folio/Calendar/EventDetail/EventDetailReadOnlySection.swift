import Planner
import SwiftUI

struct EventDetailReadOnlySection: View {
    let event: CalendarEvent
    let calendar: PlannerCalendar?

    var body: some View {
        Section {
            Label(message, systemImage: "lock.fill")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var message: String {
        if calendar?.isReadOnly ?? true {
            String(localized: "Detail.ReadOnly.Calendar", table: "EventEditor")
        } else {
            String(localized: "Detail.ReadOnly.Invitation", table: "EventEditor")
        }
    }
}
