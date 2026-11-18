import Planner
import SwiftUI

struct WorkWeekCalendarsSection: View {
    @Environment(CalendarStore.self) private var store
    @Environment(WorkWeekPreferences.self) private var workWeek

    var body: some View {
        Section {
            CalendarSelectionRow(
                title: String(localized: "Title.CalendarsAndLists", table: "CalendarSelection"),
                calendars: store.eventCalendars,
                lists: store.reminderLists,
                footer: footer,
                accessibilityPrefix: "WorkWeek.Calendar",
                isSelected: { workWeek.countsForWorkWeek(calendarIdentifier: $0.id) },
                setSelected: { workWeek.setCountsForWorkWeek($0, calendarIdentifier: $1.id) }
            )
        } footer: {
            Text(footer)
        }
    }

    private var footer: String {
        String(localized: "WorkWeek.Section.Calendars.Footer", table: "Week")
    }
}
