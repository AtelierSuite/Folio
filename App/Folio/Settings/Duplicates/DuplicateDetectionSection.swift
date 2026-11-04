import Planner
import SwiftUI

struct DuplicateDetectionSection: View {
    @Environment(CalendarStore.self) private var store
    @Environment(NotificationScheduler.self) private var scheduler
    @Environment(LeaveAlertCenter.self) private var leaveAlerts
    @Environment(ArrivalAlertCenter.self) private var arrivalAlerts

    private var calendars: [PlannerCalendar] {
        store.eventCalendars + store.reminderLists
    }

    var body: some View {
        if !calendars.isEmpty {
            Section {
                ForEach(calendars) { calendar in
                    Toggle(isOn: binding(for: calendar)) {
                        CalendarKindLabel(calendar: calendar)
                    }
                    .accessibilityIdentifier("DuplicateDetection.\(calendar.title)")
                }
            } header: {
                Text(String(localized: "Settings.Header", table: "Duplicates"))
            } footer: {
                Text(String(localized: "Settings.Footer", table: "Duplicates"))
            }
        }
    }

    private func binding(for calendar: PlannerCalendar) -> Binding<Bool> {
        Binding(
            get: { store.detectsDuplicates(in: calendar) },
            set: { isOn in
                store.setDetectsDuplicates(isOn, in: calendar)
                Task {
                    await scheduler.replan()
                    await leaveAlerts.replan()
                    await arrivalAlerts.replan()
                }
            }
        )
    }
}
