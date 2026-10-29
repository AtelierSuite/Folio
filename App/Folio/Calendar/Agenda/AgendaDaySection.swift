import Planner
import SwiftUI

struct AgendaDaySection: View {
    let day: AgendaDay
    let onOpenReminder: (ReminderItem) -> Void
    let onSelectEvent: (CalendarEvent) -> Void

    var body: some View {
        Section {
            ForEach(day.events) { event in
                HStack(spacing: 8) {
                    Button {
                        onSelectEvent(event)
                    } label: {
                        AgendaEventRow(event: event)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
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
