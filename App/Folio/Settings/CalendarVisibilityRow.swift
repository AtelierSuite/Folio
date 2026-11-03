import Planner
import SwiftUI

struct CalendarVisibilityRow: View {
    @Environment(CalendarStore.self) private var store
    let calendar: PlannerCalendar

    var body: some View {
        Toggle(isOn: Binding(
            get: { store.isVisible(calendar) },
            set: { store.setVisible($0, for: calendar) }
        )) {
            CalendarKindLabel(
                calendar: calendar,
                subtitle: calendar.isReadOnly
                    ? String(localized: "Subtitle.ReadOnly", table: "CalendarVisibility")
                    : nil
            )
        }
        .accessibilityIdentifier("CalendarVisibility.\(calendar.title)")
    }
}
