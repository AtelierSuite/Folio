import Planner
import SwiftUI

struct AgendaDaySection: View {
    let day: AgendaDay
    let onOpenReminder: (ReminderItem) -> Void

    var body: some View {
        Section {
            ForEach(day.events) { event in
                AgendaEventRow(event: event)
            }
            ForEach(day.reminders) { reminder in
                AgendaReminderRow(reminder: reminder) { onOpenReminder(reminder) }
            }
        } header: {
            Text(day.interval.start, format: .dateTime.weekday(.wide).month(.wide).day())
        }
    }
}
