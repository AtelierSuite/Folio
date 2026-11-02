import Planner
import SwiftUI

struct EventCalendarPicker: View {
    @Binding var selection: String
    let calendars: [PlannerCalendar]

    var body: some View {
        Picker(String(localized: "Field.Calendar", table: "EventEditor"), selection: $selection) {
            ForEach(CalendarAccountGroup.groups(from: calendars)) { group in
                Section(group.title) {
                    ForEach(group.calendars) { calendar in
                        Label {
                            Text(calendar.title)
                        } icon: {
                            Image(coloredSymbol: "circle.fill", color: calendar.color)
                        }
                        .tag(calendar.id)
                    }
                }
            }
        }
        .tint(calendars.first { $0.id == selection }?.color.color)
    }
}
