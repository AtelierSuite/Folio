import Planner
import SwiftUI

struct WatchDayGridScreen: View {
    let firstDay: Date
    let dayCount: Int

    @Environment(WatchCalendarModel.self) private var model
    @State private var events: [CalendarEvent] = []

    var body: some View {
        let days = TimelineDays(startingOn: firstDay, count: dayCount, calendar: .current)
        TimelineView(.everyMinute) { context in
            WatchDayGridView(
                days: days,
                events: events,
                layout: TimelineLayoutEngine(days: days).layout(events.map { TimelineEntry(event: $0) }),
                now: context.date
            )
        }
        .task(id: WatchEventsLoadKey(firstDay: firstDay, dayCount: dayCount, revision: model.revision)) {
            events = await model.events(
                for: .days(startingOn: firstDay, count: dayCount, calendar: .current),
                at: .now
            )
        }
    }
}
