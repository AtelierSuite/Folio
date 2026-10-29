import Planner
import SwiftUI

struct WidgetEventTimeText: View {
    let event: CalendarEvent

    var body: some View {
        if event.isAllDay {
            Text(String(localized: "Event.AllDay", table: "Widgets"))
        } else {
            Text(verbatim: "\(Self.time(event.startDate)) – \(Self.time(event.endDate))")
        }
    }

    static func time(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
}
