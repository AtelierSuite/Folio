import Planner
import SwiftUI
import WidgetKit

struct RemindersWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: FolioWidgetEntry

    var body: some View {
        if !entry.snapshot.canReadReminders {
            WidgetAccessRequiredView(kind: .reminder)
                .padding()
        } else {
            WidgetTitleBarLayout {
                RemindersHeader(count: entry.snapshot.reminders.count)
            } content: {
                RemindersChecklist(reminders: entry.snapshot.checklist(limit: rowLimit))
            }
        }
    }

    private var rowLimit: Int {
        switch family {
        case .systemLarge, .systemExtraLarge: 10
        default: 3
        }
    }
}

struct RemindersChecklist: View {
    let reminders: [ReminderItem]

    var body: some View {
        if reminders.isEmpty {
            WidgetEmptyText(text: String(localized: "Reminders.AllDone", table: "Widgets"))
        } else {
            ViewThatFits(in: .vertical) {
                ForEach((1...reminders.count).reversed(), id: \.self) { rowCount in
                    RemindersChecklistRows(reminders: reminders.prefix(rowCount))
                }
            }
        }
    }
}

struct RemindersChecklistRows: View {
    let reminders: ArraySlice<ReminderItem>

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(reminders) { reminder in
                WidgetReminderRow(reminder: reminder)
            }
        }
    }
}

struct RemindersHeader: View {
    let count: Int

    var body: some View {
        WidgetTitleBar {
            Label(String(localized: "Reminders.Title", table: "Widgets"), systemImage: "checklist")
            Spacer(minLength: 0)
            Text(count, format: .number)
        }
    }
}
