import Planner
import SwiftUI

struct DuplicateDetectionSection: View {
    @Environment(CalendarStore.self) private var store
    @Environment(NotificationScheduler.self) private var scheduler
    @Environment(LeaveAlertCenter.self) private var leaveAlerts
    @Environment(ArrivalAlertCenter.self) private var arrivalAlerts

    var body: some View {
        if !store.eventCalendars.isEmpty || !store.reminderLists.isEmpty {
            Section {
                CalendarSelectionRow(
                    title: String(localized: "Title.CalendarsAndLists", table: "CalendarSelection"),
                    sheetTitle: String(localized: "Settings.Header", table: "Duplicates"),
                    calendars: store.eventCalendars,
                    lists: store.reminderLists,
                    footer: String(localized: "Settings.Footer", table: "Duplicates"),
                    accessibilityPrefix: "DuplicateDetection",
                    isSelected: { store.detectsDuplicates(in: $0) },
                    setSelected: setDetectsDuplicates
                )
            } header: {
                Text(String(localized: "Settings.Header", table: "Duplicates"))
            } footer: {
                Text(String(localized: "Settings.Footer", table: "Duplicates"))
            }
        }
    }

    private func setDetectsDuplicates(_ isOn: Bool, in calendar: PlannerCalendar) {
        store.setDetectsDuplicates(isOn, in: calendar)
        Task {
            await scheduler.replan()
            await leaveAlerts.replan()
            await arrivalAlerts.replan()
        }
    }
}
