import Planner
import SwiftUI

struct EventCalendarPicker: View {
    @Binding var selection: String
    let calendars: [PlannerCalendar]
    var title = String(localized: "Field.Calendar", table: "EventEditor")

    var body: some View {
        Picker(title, selection: $selection) {
            ForEach(CalendarAccountGroup.groups(from: calendars)) { group in
                Section(group.title) {
                    ForEach(group.calendars) { calendar in
                        Label {
                            Text(calendar.title)
                        } icon: {
                            Image(calendarDot: calendar.color)
                        }
                        .tag(calendar.id)
                    }
                }
            }
        }
        .tint(calendars.first { $0.id == selection }?.color.color)
    }
}
