import SwiftUI

struct AgendaDaySection: View {
    let day: AgendaDay

    var body: some View {
        Section {
            ForEach(day.events) { event in
                AgendaEventRow(event: event)
            }
            ForEach(day.reminders) { reminder in
                AgendaReminderRow(reminder: reminder)
            }
        } header: {
            Text(day.interval.start, format: .dateTime.weekday(.wide).month(.wide).day())
        }
    }
}
