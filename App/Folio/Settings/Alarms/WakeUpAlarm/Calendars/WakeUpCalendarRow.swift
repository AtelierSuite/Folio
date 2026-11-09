import Planner
import SwiftUI

struct WakeUpCalendarRow: View {
    @Environment(WakeUpAlarmCenter.self) private var wakeUpAlarms
    let calendar: PlannerCalendar

    var body: some View {
        Toggle(isOn: Binding(
            get: { wakeUpAlarms.includesCalendar(calendar.id) },
            set: { isIncluded in
                Task { await wakeUpAlarms.setIncludesCalendar(isIncluded, calendarIdentifier: calendar.id) }
            }
        )) {
            CalendarKindLabel(calendar: calendar)
        }
        .accessibilityIdentifier("WakeUpCalendar.\(calendar.title)")
    }
}
