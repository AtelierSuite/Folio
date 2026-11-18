import Planner
import SwiftUI

struct AgendaDaySection: View {
    let day: AgendaDay
    let onOpenReminder: (ReminderItem) -> Void

    var body: some View {
        Section {
            ForEach(day.eventGroups) { group in
                AgendaEventListRow(group: group, showsDivider: group.id != day.eventGroups.last?.id)
                    .agendaListRow()
            }
            ForEach(day.reminders) { reminder in
                AgendaReminderCard(
                    reminder: reminder,
                    isFirst: reminder.id == day.reminders.first?.id,
                    isLast: reminder.id == day.reminders.last?.id
                ) { onOpenReminder(reminder) }
                .agendaListRow()
            }
        } header: {
            AgendaDaySectionHeader(date: day.interval.start)
                .agendaListRow()
        }
    }
}
