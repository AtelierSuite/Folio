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
            HStack(spacing: 10) {
                Circle()
                    .fill(calendar.color.color)
                    .frame(width: 12, height: 12)
                Text(calendar.title)
            }
        }
        .accessibilityIdentifier("WorkWeek.Calendar.\(calendar.title)")
    }
}
