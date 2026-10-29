import Planner
import SwiftUI

struct TodayAgendaList: View {
    let entry: FolioWidgetEntry
    let rowLimit: Int

    var body: some View {
        let events = entry.snapshot.canReadEvents ? entry.snapshot.todayEvents(at: entry.date, calendar: .current) : []
        let reminders = entry.snapshot.canReadReminders
            ? entry.snapshot.todayReminders(at: entry.date, calendar: .current)
            : []
        let shownEvents = Array(events.prefix(rowLimit))
        let shownReminders = Array(reminders.prefix(rowLimit - shownEvents.count))
        let hiddenCount = events.count + reminders.count - shownEvents.count - shownReminders.count
        VStack(alignment: .leading, spacing: 6) {
            if shownEvents.isEmpty && shownReminders.isEmpty {
                WidgetEmptyText(text: String(localized: "Today.Empty", table: "Widgets"))
            } else {
                ForEach(shownEvents) { event in
                    WidgetEventRow(event: event)
                }
                ForEach(shownReminders) { reminder in
                    WidgetReminderRow(reminder: reminder)
                }
                if hiddenCount > 0 {
                    Text(String(localized: "Today.More \(hiddenCount)", table: "Widgets"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
