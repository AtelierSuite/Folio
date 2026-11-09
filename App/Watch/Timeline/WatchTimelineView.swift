import Planner
import SwiftUI

struct WatchTimelineView: View {
    @Environment(WatchCalendarModel.self) private var model
    @State private var events: [CalendarEvent] = []
    @State private var hasLoaded = false

    var body: some View {
        TimelineView(.everyMinute) { context in
            let agenda = WatchAgenda(events: events, from: context.date, calendar: .current)
            if hasLoaded && agenda.isEmpty {
                WatchTimelineEmptyView()
            } else {
                WatchAgendaList(agenda: agenda, now: context.date)
            }
        }
        .task(id: loadKey) {
            let now = Date.now
            events = await model.events(
                for: .days(startingOn: now, count: WatchAgenda.defaultDayCount, calendar: .current),
                at: now
            )
            hasLoaded = true
        }
    }

    private var loadKey: WatchEventsLoadKey {
        WatchEventsLoadKey(
            firstDay: Calendar.current.startOfDay(for: .now),
            dayCount: WatchAgenda.defaultDayCount,
            revision: model.revision
        )
    }
}
