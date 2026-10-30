import Planner
import SwiftUI

struct AllDayAlertTimesView: View {
    @Environment(CalendarStore.self) private var store

    var body: some View {
        Form {
            if store.eventCalendars.isEmpty {
                Text(String(localized: "AllDay.Empty", table: "Notifications"))
                    .foregroundStyle(.secondary)
            } else {
                Section {
                    ForEach(store.eventCalendars) { AllDayAlertTimeRow(calendar: $0) }
                } footer: {
                    Text(String(localized: "AllDay.Footer", table: "Notifications"))
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(String(localized: "AllDay.Title", table: "Notifications"))
    }
}
