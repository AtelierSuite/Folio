import Planner
import SwiftUI

struct TodayAgendaRows: View {
    let events: [CalendarEvent]
    let reminders: [ReminderItem]
    let rowLimit: Int

    var body: some View {
        let shownEvents = Array(events.prefix(rowLimit))
        let shownReminders = Array(reminders.prefix(rowLimit - shownEvents.count))
        let hiddenCount = events.count + reminders.count - shownEvents.count - shownReminders.count
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(shownEvents) { event in
                    WidgetEventRow(event: event)
                }
                ForEach(shownReminders) { reminder in
                    WidgetReminderRow(reminder: reminder)
                }
            }
            if hiddenCount > 0 {
                Spacer(minLength: 6)
                Text(String(localized: "Today.More \(hiddenCount)", table: "Widgets"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
