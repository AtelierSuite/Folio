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
            HStack(spacing: 10) {
                Circle()
                    .fill(calendar.color.color)
                    .frame(width: 12, height: 12)
                VStack(alignment: .leading, spacing: 2) {
                    Text(calendar.title)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .accessibilityIdentifier("CalendarVisibility.\(calendar.title)")
    }

    private var subtitle: String {
        guard calendar.isReadOnly else { return calendar.sourceTitle }
        return String(
            localized: "Subtitle.ReadOnly \(calendar.sourceTitle)",
            table: "CalendarVisibility"
        )
    }
}
