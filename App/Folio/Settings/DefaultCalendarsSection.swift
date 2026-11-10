import Planner
import SwiftUI

struct DefaultCalendarsSection: View {
    @Environment(CalendarStore.self) private var store

    var body: some View {
        if !store.writableEventCalendars.isEmpty || !store.writableReminderLists.isEmpty {
            Section {
                if !store.writableEventCalendars.isEmpty {
                    EventCalendarPicker(
                        selection: selection(store.defaultEventCalendarIdentifier, in: store.writableEventCalendars),
                        calendars: store.writableEventCalendars,
                        title: String(localized: "Defaults.Calendar", table: "CalendarVisibility")
                    )
                    .accessibilityIdentifier("DefaultCalendarPicker")
                }
                if !store.writableReminderLists.isEmpty {
                    EventCalendarPicker(
                        selection: selection(store.defaultReminderListIdentifier, in: store.writableReminderLists),
                        calendars: store.writableReminderLists,
                        title: String(localized: "Defaults.List", table: "CalendarVisibility")
                    )
                    .accessibilityIdentifier("DefaultListPicker")
                }
            } footer: {
                Text(String(localized: "Defaults.Footer", table: "CalendarVisibility"))
            }
        }
    }

    private func selection(_ current: String?, in calendars: [PlannerCalendar]) -> Binding<String> {
        Binding(
            get: { current ?? "" },
            set: { identifier in
                if let calendar = calendars.first(where: { $0.id == identifier }) {
                    store.setDefault(calendar)
                }
            }
        )
    }
}
