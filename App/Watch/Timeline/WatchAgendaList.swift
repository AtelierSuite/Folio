import Planner
import SwiftUI

struct WatchAgendaList: View {
    let agenda: WatchAgenda
    let now: Date

    var body: some View {
        List {
            ForEach(agenda.days) { day in
                Section {
                    if day.isEmpty {
                        Text(String(localized: "Timeline.NoMoreEventsToday", table: "Watch"))
                            .foregroundStyle(.secondary)
                    }
                    ForEach(day.allDayEvents + day.timedEvents) { event in
                        NavigationLink(value: event) {
                            WatchEventRow(event: event, now: now)
                        }
                    }
                } header: {
                    WatchAgendaDayHeader(date: day.date)
                }
            }
        }
    }
}
