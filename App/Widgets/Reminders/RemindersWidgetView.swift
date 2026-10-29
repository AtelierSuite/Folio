import Planner
import SwiftUI
import WidgetKit

struct RemindersWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: FolioWidgetEntry

    var body: some View {
        if !entry.snapshot.canReadReminders {
            WidgetAccessRequiredView(kind: .reminder)
        } else {
            VStack(alignment: .leading, spacing: 6) {
                RemindersHeader(count: entry.snapshot.reminders.count)
                let reminders = entry.snapshot.checklist(limit: rowLimit)
                if reminders.isEmpty {
                    WidgetEmptyText(text: String(localized: "Reminders.AllDone", table: "Widgets"))
                } else {
                    ForEach(reminders) { reminder in
                        WidgetReminderRow(reminder: reminder)
                    }
                    Spacer(minLength: 0)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private var rowLimit: Int {
        switch family {
        case .systemLarge, .systemExtraLarge: 10
        default: 4
        }
    }
}

struct RemindersHeader: View {
    let count: Int

    var body: some View {
        HStack {
            Label(String(localized: "Reminders.Title", table: "Widgets"), systemImage: "checklist")
                .font(.caption.weight(.bold))
                .foregroundStyle(.tint)
                .widgetAccentable()
            Spacer(minLength: 0)
            Text(count, format: .number)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }
}
