import Planner
import SwiftUI
import WidgetKit

/// Shown when Folio hasn't been allowed to read calendars or reminders; the widget can't ask for access itself.
struct WidgetAccessRequiredView: View {
    let kind: CalendarItemKind

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: kind == .event ? "calendar" : "checklist")
                .font(.title3)
                .foregroundStyle(.tint)
                .widgetAccentable()
            Text(String(localized: "Access.Title", table: "Widgets"))
                .font(.caption.weight(.semibold))
            Text(message)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var message: String {
        switch kind {
        case .event: String(localized: "Access.Calendars", table: "Widgets")
        case .reminder: String(localized: "Access.Reminders", table: "Widgets")
        }
    }
}
