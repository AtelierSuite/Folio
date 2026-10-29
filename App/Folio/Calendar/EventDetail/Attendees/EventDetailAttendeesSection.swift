import Planner
import SwiftUI

struct EventDetailAttendeesSection: View {
    let event: CalendarEvent

    private var invitees: [EventParticipant] {
        event.attendees.filter { $0.id != event.organizer?.id }
    }

    var body: some View {
        if event.organizer != nil || !event.attendees.isEmpty {
            Section {
                if let organizer = event.organizer {
                    LabeledContent(String(localized: "Detail.Organizer", table: "Invitations")) {
                        Text(organizer.isCurrentUser
                            ? String(localized: "Attendee.You", table: "Invitations")
                            : organizer.displayName)
                    }
                    .accessibilityIdentifier("EventDetailOrganizer")
                }
                ForEach(invitees) { attendee in
                    EventAttendeeRow(attendee: attendee)
                }
            } header: {
                Text(String(localized: "Detail.Invitees", table: "Invitations"))
            } footer: {
                let summary = event.attendeeSummary
                if summary.total > 0 {
                    Text(summary.description())
                        .accessibilityIdentifier("EventDetailAttendeeSummary")
                }
            }
        }
    }
}
