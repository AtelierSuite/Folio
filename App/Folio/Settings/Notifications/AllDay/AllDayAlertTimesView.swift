import Planner
import SwiftUI

struct AllDayAlertTimesView: View {
    @Environment(CalendarStore.self) private var store
    @Environment(NotificationScheduler.self) private var scheduler

    var body: some View {
        Form {
            if store.eventCalendars.isEmpty {
                Text(String(localized: "AllDay.Empty", table: "Notifications"))
                    .foregroundStyle(.secondary)
            } else {
                CalendarAccountSections(
                    calendars: store.eventCalendars,
                    footer: String(localized: "AllDay.Footer", table: "Notifications")
                ) { AllDayAlertTimeRow(calendar: $0) }
                .disabled(!scheduler.isEnabled || !scheduler.includesEvents)
            }
        }
        .accessibilityIdentifier("AllDayAlertTimes")
        .settingsCategoryStyle(.allDayAlerts)
    }
}
