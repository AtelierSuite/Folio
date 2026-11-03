import Planner
import SwiftUI

struct CalendarAddMenu: View {
    @Environment(\.platformCapabilities) private var capabilities
    @Binding var composer: CalendarComposer?

    var body: some View {
        Menu(String(localized: "Toolbar.Add", table: "Calendar"), systemImage: "plus") {
            Button(String(localized: "Add.Event", table: "Calendar"), systemImage: "calendar.badge.plus") {
                composer = .newEvent
            }
            Button(String(localized: "Add.Reminder", table: "Calendar"), systemImage: "checklist") {
                composer = .newReminder
            }
            if capabilities.supports(.alarms) {
                Button(String(localized: "Add.Alarm", table: "StandaloneAlarms"), systemImage: "alarm") {
                    composer = .newAlarm
                }
                .accessibilityIdentifier("AddMenu.Alarm")
            }
        }
    }
}
