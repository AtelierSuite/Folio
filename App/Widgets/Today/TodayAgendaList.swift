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
        let largestRowCount = min(rowLimit, events.count + reminders.count)
        Group {
            if largestRowCount == 0 {
                WidgetEmptyText(text: String(localized: "Today.Empty", table: "Widgets"))
            } else {
                ViewThatFits(in: .vertical) {
                    ForEach((1...largestRowCount).reversed(), id: \.self) { rowCount in
                        TodayAgendaRows(events: events, reminders: reminders, rowLimit: rowCount)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
