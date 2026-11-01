import Planner
import SwiftUI

struct CalendarAccountSections<Row: View>: View {
    let calendars: [PlannerCalendar]
    var kindTitle: String?
    var footer: String?
    @ViewBuilder let row: (PlannerCalendar) -> Row

    private var groups: [CalendarAccountGroup] {
        CalendarAccountGroup.groups(from: calendars)
    }

    var body: some View {
        let groups = groups
        ForEach(groups) { group in
            Section {
                ForEach(group.calendars) { calendar in
                    row(calendar)
                }
            } header: {
                Text(group.header(kindTitle: kindTitle))
            } footer: {
                if let footer, group.id == groups.last?.id {
                    Text(footer)
                }
            }
        }
    }
}
