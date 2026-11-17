import Planner
import SwiftUI

struct CalendarSelectionList: View {
    let calendars: [PlannerCalendar]
    var lists: [PlannerCalendar] = []
    var footer: String?
    let accessibilityPrefix: String
    let isSelected: (PlannerCalendar) -> Bool
    let setSelected: (Bool, PlannerCalendar) -> Void

    var body: some View {
        Form {
            if calendars.isEmpty && lists.isEmpty {
                Text(String(localized: "Empty", table: "CalendarSelection"))
                    .foregroundStyle(.secondary)
            } else {
                CalendarAccountSections(calendars: calendars, lists: lists, footer: footer) { calendar in
                    Toggle(isOn: Binding(
                        get: { isSelected(calendar) },
                        set: { setSelected($0, calendar) }
                    )) {
                        CalendarKindLabel(calendar: calendar)
                    }
                    .accessibilityIdentifier("\(accessibilityPrefix).\(calendar.title)")
                }
            }
        }
        .formStyle(.grouped)
    }
}
