import AppIntents
import Planner
import SwiftUI
import WidgetKit

struct WidgetReminderRow: View {
    let reminder: ReminderItem

    var body: some View {
        HStack(spacing: 6) {
            Button(intent: completeIntent) {
                Image(systemName: "circle")
                    .font(.body)
                    .foregroundStyle(reminder.color.color)
                    .widgetAccentable()
            }
            .buttonStyle(.plain)
            .disabled(reminder.isReadOnly)
            .accessibilityLabel(String(localized: "Reminder.MarkCompleted", table: "Widgets"))
            VStack(alignment: .leading, spacing: 0) {
                Text(reminder.title)
                    .font(.caption)
                    .lineLimit(1)
                if reminder.hasDueTime, let dueDate = reminder.dueDate {
                    Text(dueDate, format: .dateTime.hour().minute())
                        .font(.caption2)
                        .foregroundStyle(dueDate < .now ? .red : .secondary)
                }
            }
            Spacer(minLength: 0)
        }
    }

    private var completeIntent: ToggleReminderIntent {
        ToggleReminderIntent(reminderIdentifier: reminder.reference.localIdentifier, isCompleted: true)
    }
}
