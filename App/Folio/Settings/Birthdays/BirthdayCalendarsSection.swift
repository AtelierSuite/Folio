import Planner
import SwiftUI

struct BirthdayCalendarsSection: View {
    @Environment(CalendarStore.self) private var store
    @Environment(NotificationScheduler.self) private var scheduler

    var body: some View {
        Section {
            CalendarSelectionRow(
                title: String(localized: "Calendars", table: "Birthdays"),
                calendars: store.markableBirthdayCalendars,
                footer: footer,
                accessibilityPrefix: "Birthdays.Calendar",
                isSelected: { store.markedBirthdayCalendarIdentifiers.contains($0.id) },
                setSelected: { isMarked, calendar in
                    Task {
                        await store.setMarkedAsBirthdays(isMarked, for: calendar)
                        await scheduler.replan()
                    }
                }
            )
        } footer: {
            Text(footer)
        }
    }

    private var footer: String {
        String(localized: "Calendars.Footer", table: "Birthdays")
    }
}
