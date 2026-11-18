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
            if !day.reminders.isEmpty {
                AgendaReminderGroup(reminders: day.reminders, onOpen: onOpenReminder)
                    .agendaListRow()
            }
        } header: {
            AgendaDaySectionHeader(date: day.interval.start)
                .agendaListRow()
        }
    }
}
