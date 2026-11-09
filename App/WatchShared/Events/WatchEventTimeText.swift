import Planner
import SwiftUI

/// "All Day", "Until 11:00" while the event is on, or its start and end.
struct WatchEventTimeText: View {
    let event: CalendarEvent
    var now = Date.now

    var body: some View {
        Text(verbatim: Self.description(of: event, at: now))
    }

    static func description(of event: CalendarEvent, at now: Date) -> String {
        if event.isAllDay {
            return String(localized: "Event.AllDay", table: "WatchShared")
        }
        if event.startDate <= now && now < event.endDate {
            return String(localized: "Event.Until \(clock(event.endDate))", table: "WatchShared")
        }
        guard event.endDate > event.startDate else { return clock(event.startDate) }
        return (event.startDate..<event.endDate).formatted(.interval.hour().minute())
    }

    static func clock(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
}
