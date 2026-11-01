import Planner
import SwiftUI

struct WorkWeekCalendarRow: View {
    @Environment(WorkWeekPreferences.self) private var workWeek
    let calendar: PlannerCalendar

    var body: some View {
        Toggle(isOn: Binding(
            get: { workWeek.countsForWorkWeek(calendarIdentifier: calendar.id) },
            set: { workWeek.setCountsForWorkWeek($0, calendarIdentifier: calendar.id) }
        )) {
            CalendarKindLabel(calendar: calendar)
        }
        .accessibilityIdentifier("WorkWeek.Calendar.\(calendar.title)")
    }
}
