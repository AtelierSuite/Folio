import Planner
import SwiftUI
import WidgetKit

struct HourlyWidgetView: View {
    let entry: FolioWidgetEntry

    var body: some View {
        content
            .widgetURL(CalendarDeepLink.url(forDay: entry.date))
    }

    @ViewBuilder
    private var content: some View {
        if entry.snapshot.canReadEvents {
            WidgetTitleBarLayout {
                WidgetDateTitleBar(date: entry.date)
            } content: {
                HourlyScheduleGrid(
                    schedule: HourlySchedule(events: entry.snapshot.events, at: entry.date, calendar: .current)
                )
            }
        } else {
            WidgetAccessRequiredView(kind: .event)
                .padding()
        }
    }
}
