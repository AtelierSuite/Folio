import Planner
import SwiftUI
import WidgetKit

#if os(iOS)
struct RemainingRemindersView: View {
    @Environment(\.widgetFamily) private var family
    let entry: FolioWidgetEntry

    var body: some View {
        let reminders = entry.snapshot.todayReminders(at: entry.date, calendar: .current)
        if !entry.snapshot.canReadReminders {
            Label(String(localized: "Access.Short", table: "Widgets"), systemImage: "checklist")
                .font(.caption)
        } else {
            switch family {
            case .accessoryInline:
                Label(
                    String(localized: "RemainingReminders.Count \(reminders.count)", table: "Widgets"),
                    systemImage: "checklist"
                )
            case .accessoryRectangular:
                VStack(alignment: .leading, spacing: 0) {
                    Label(String(localized: "Reminders.Title", table: "Widgets"), systemImage: "checklist")
                        .font(.headline)
                        .widgetAccentable()
                    Text(String(localized: "RemainingReminders.Count \(reminders.count)", table: "Widgets"))
                    if let first = reminders.first {
                        Text(first.title)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            default:
                ZStack {
                    AccessoryWidgetBackground()
                    VStack(spacing: 0) {
                        Image(systemName: "checklist")
                            .font(.caption)
                            .widgetAccentable()
                        Text(reminders.count, format: .number)
                            .font(.title3.weight(.bold))
                    }
                }
            }
        }
    }
}
#endif
