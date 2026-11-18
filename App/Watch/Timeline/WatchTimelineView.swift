import Planner
import SwiftUI

struct WatchTimelineView: View {
    @Environment(WatchCalendarModel.self) private var model
    @State private var events: [CalendarEvent] = []
    @State private var hasLoaded = false

    var body: some View {
        TimelineView(.everyMinute) { context in
            let agenda = WatchAgenda(events: events, from: context.date, calendar: .current)
            Group {
                if hasLoaded && agenda.isEmpty {
                    WatchTimelineEmptyView()
                } else {
                    WatchAgendaList(agenda: agenda, now: context.date)
                }
            }
            .task(id: loadKey(for: context.date)) {
                await loadEvents(startingOn: context.date)
            }
        }
    }

    private func loadKey(for date: Date) -> WatchEventsLoadKey {
        WatchEventsLoadKey(
            firstDay: Calendar.current.startOfDay(for: date),
            dayCount: WatchAgenda.defaultDayCount,
            revision: model.revision
        )
    }

    private func loadEvents(startingOn date: Date) async {
        events = await model.events(
            for: .days(startingOn: date, count: WatchAgenda.defaultDayCount, calendar: .current),
            at: .now
        )
        hasLoaded = true
    }
}
