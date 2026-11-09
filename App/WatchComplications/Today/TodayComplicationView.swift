import Planner
import SwiftUI
import WidgetKit

struct TodayComplicationView: View {
    let entry: ComplicationEntry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        if entry.snapshot.canReadEvents {
            let events = entry.snapshot.todayEvents(at: entry.date, calendar: .current)
            if family == .accessoryCircular {
                TodayCircularView(date: entry.date, events: events)
            } else {
                TodayRectangularView(date: entry.date, events: events)
            }
        } else {
            ComplicationAccessView()
        }
    }
}
