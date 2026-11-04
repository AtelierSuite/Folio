import Planner
import SwiftUI

struct AgendaDaySection: View {
    @Environment(\.eventActions) private var actions
    let day: AgendaDay
    let onOpenReminder: (ReminderItem) -> Void

    var body: some View {
        Section {
            ForEach(day.eventGroups) { group in
                HStack(spacing: 8) {
                    AgendaEventRow(event: group.primary, duplicateCount: group.count)
                        .accessibilityElement(children: .combine)
                        .eventInteractions(group.primary, actions: actions)
                    if let meetingLink = group.primary.meetingLink {
                        JoinMeetingButton(link: meetingLink, style: .capsule)
                    }
                }
            }
            ForEach(day.reminders) { reminder in
                AgendaReminderRow(reminder: reminder) { onOpenReminder(reminder) }
            }
        } header: {
            AgendaDaySectionHeader(date: day.interval.start)
        }
    }
}
