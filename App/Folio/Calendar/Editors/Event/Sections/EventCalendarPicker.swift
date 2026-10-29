import Planner
import SwiftUI

struct EventCalendarPicker: View {
    @Binding var selection: String
    let calendars: [PlannerCalendar]

    var body: some View {
        Picker(String(localized: "Field.Calendar", table: "EventEditor"), selection: $selection) {
            ForEach(calendars) { calendar in
                Text(calendar.title)
                    .tag(calendar.id)
            }
        }
        .tint(calendars.first { $0.id == selection }?.color.color)
    }
}
