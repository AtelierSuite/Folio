import Planner
import SwiftUI
import WidgetKit

struct MiniMonthWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: FolioWidgetEntry

    var body: some View {
        let grid = MonthGrid(containing: entry.date, calendar: .current)
        Group {
            if family == .systemMedium {
                HStack(alignment: .top, spacing: 12) {
                    MiniMonthGridView(grid: grid, today: entry.date, eventDays: entry.snapshot.daysWithEvents(in: grid))
                    TodayAgendaList(entry: entry, rowLimit: 4)
                }
            } else {
                MiniMonthGridView(grid: grid, today: entry.date, eventDays: entry.snapshot.daysWithEvents(in: grid))
            }
        }
        .widgetURL(CalendarDeepLink.url(forDay: entry.date))
    }
}
