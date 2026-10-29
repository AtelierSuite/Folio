import Planner
import SwiftUI

struct AgendaDaySection: View {
    @Environment(\.eventActions) private var actions
    let day: AgendaDay
    let onOpenReminder: (ReminderItem) -> Void

    var body: some View {
        Section {
            ForEach(day.events) { event in
                HStack(spacing: 8) {
                    AgendaEventRow(event: event)
                        .accessibilityElement(children: .combine)
                        .eventInteractions(event, actions: actions)
                    if let meetingLink = event.meetingLink {
                        JoinMeetingButton(link: meetingLink, style: .capsule)
                    }
                }
            }
            ForEach(day.reminders) { reminder in
                AgendaReminderRow(reminder: reminder) { onOpenReminder(reminder) }
            }
        } header: {
            Text(day.interval.start, format: .dateTime.weekday(.wide).month(.wide).day())
        }
    }
}
