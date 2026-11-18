import Planner
import SwiftUI

struct BirthdayVisibilitySection: View {
    @Environment(CalendarStore.self) private var store
    let calendar: PlannerCalendar

    var body: some View {
        Section {
            Toggle(String(localized: "Show", table: "Birthdays"), isOn: Binding(
                get: { store.isVisible(calendar) },
                set: { store.setVisible($0, for: calendar) }
            ))
            .accessibilityIdentifier("BirthdaysVisibleToggle")
        } footer: {
            Text(String(localized: "Show.Footer", table: "Birthdays"))
        }
    }
}
