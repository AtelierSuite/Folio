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
            CalendarKindLabel(calendar: calendar, subtitle: subtitle)
        }
        .contextMenu {
            if !calendar.isReadOnly && !store.isDefault(calendar) {
                Button(setDefaultTitle, systemImage: "checkmark.circle") {
                    store.setDefault(calendar)
                }
            }
        }
        .accessibilityIdentifier("CalendarVisibility.\(calendar.title)")
    }

    private var subtitle: String? {
        if calendar.isReadOnly {
            return String(localized: "Subtitle.ReadOnly", table: "CalendarVisibility")
        }
        return store.isDefault(calendar) ? String(localized: "Subtitle.Default", table: "CalendarVisibility") : nil
    }

    private var setDefaultTitle: String {
        switch calendar.kind {
        case .event: String(localized: "Action.SetDefaultCalendar", table: "CalendarVisibility")
        case .reminder: String(localized: "Action.SetDefaultList", table: "CalendarVisibility")
        }
    }
}
