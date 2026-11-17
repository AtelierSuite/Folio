import Planner
import SwiftUI

struct WakeUpCalendarsRow: View {
    @Environment(WakeUpAlarmCenter.self) private var wakeUpAlarms
    @Environment(CalendarStore.self) private var store

    var body: some View {
        CalendarSelectionRow(
            title: String(localized: "Title.Calendars", table: "CalendarSelection"),
            calendars: store.eventCalendars,
            footer: String(localized: "Calendars.Footer", table: "WakeUpAlarms"),
            accessibilityPrefix: "WakeUpCalendar",
            isSelected: { wakeUpAlarms.includesCalendar($0.id) },
            setSelected: { isIncluded, calendar in
                Task { await wakeUpAlarms.setIncludesCalendar(isIncluded, calendarIdentifier: calendar.id) }
            }
        )
    }
}
