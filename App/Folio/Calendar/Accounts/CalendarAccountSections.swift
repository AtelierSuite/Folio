import Planner
import SwiftUI

struct CalendarAccountSections<Row: View>: View {
    let calendars: [PlannerCalendar]
    var lists: [PlannerCalendar] = []
    var footer: String?
    @ViewBuilder let row: (PlannerCalendar) -> Row

    private var groups: [CalendarAccountGroup] {
        CalendarAccountGroup.groups(calendars: calendars, lists: lists)
    }

    var body: some View {
        let groups = groups
        ForEach(groups) { group in
            Section {
                ForEach(group.calendars) { calendar in
                    row(calendar)
                }
            } header: {
                Text(group.title)
            } footer: {
                if let footer, group.id == groups.last?.id {
                    Text(footer)
                }
            }
        }
    }
}
