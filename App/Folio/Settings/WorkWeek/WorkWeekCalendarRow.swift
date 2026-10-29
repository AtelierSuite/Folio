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
                VStack(alignment: .leading, spacing: 2) {
                    Text(calendar.title)
                    Text(calendar.sourceTitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .accessibilityIdentifier("WorkWeek.Calendar.\(calendar.title)")
    }
}
