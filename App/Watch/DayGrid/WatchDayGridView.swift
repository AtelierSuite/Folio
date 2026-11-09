import Planner
import SwiftUI

struct WatchDayGridView: View {
    let days: TimelineDays
    let events: [CalendarEvent]
    let layout: TimelineLayout
    let now: Date

    var body: some View {
        VStack(spacing: 2) {
            if days.count > 1 {
                WatchDayColumnHeaders(days: days)
            }
            WatchAllDayStrip(days: days, events: events.filter(\.isAllDay))
            ScrollViewReader { proxy in
                ScrollView {
                    WatchHourGrid(layout: layout, eventsByID: eventsByID, now: now)
                }
                .onAppear {
                    proxy.scrollTo(WatchHourGrid.hourID(firstVisibleHour), anchor: .top)
                }
                .onChange(of: days) {
                    proxy.scrollTo(WatchHourGrid.hourID(firstVisibleHour), anchor: .top)
                }
            }
        }
    }

    private var eventsByID: [String: CalendarEvent] {
        Dictionary(events.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
    }

    /// An hour before now on today's page, otherwise the first event's hour, or the start of a working day.
    private var firstVisibleHour: Int {
        if let position = days.position(of: now) {
            return max(Int(position.hour) - 1, 0)
        }
        let firstStart = layout.timedPlacements.map(\.startHour).min()
        return Int(firstStart ?? WatchHourGrid.workingDayStartHour)
    }
}
