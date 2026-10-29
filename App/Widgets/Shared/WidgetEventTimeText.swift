import Planner
import SwiftUI

/// The event's time, prefixed with its weekday when it isn't today.
struct WidgetEventTimeText: View {
    let event: CalendarEvent

    var body: some View {
        Text(verbatim: [dayPrefix, timeRange].compactMap(\.self).joined(separator: " "))
    }

    private var dayPrefix: String? {
        Calendar.current.isDateInToday(event.startDate)
            ? nil
            : event.startDate.formatted(.dateTime.weekday(.abbreviated))
    }

    private var timeRange: String {
        if event.isAllDay {
            return String(localized: "Event.AllDay", table: "Widgets")
        }
        return "\(Self.time(event.startDate)) – \(Self.time(event.endDate))"
    }

    static func time(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
}
