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
                if let dueDate = reminder.dueDate, let dueText {
                    Text(verbatim: dueText)
                        .font(.caption2)
                        .foregroundStyle(dueDate < .now ? .red : .secondary)
                }
            }
            Spacer(minLength: 0)
        }
    }

    private var dueText: String? {
        guard let dueDate = reminder.dueDate else { return nil }
        let isToday = Calendar.current.isDateInToday(dueDate)
        let day = isToday ? nil : dueDate.formatted(.dateTime.weekday(.abbreviated))
        let time = reminder.hasDueTime ? WidgetEventTimeText.time(dueDate) : nil
        let parts = [day, time].compactMap(\.self)
        return parts.isEmpty ? nil : parts.joined(separator: " ")
    }

    private var completeIntent: ToggleReminderIntent {
        ToggleReminderIntent(reminderIdentifier: reminder.reference.localIdentifier, isCompleted: true)
    }
}
