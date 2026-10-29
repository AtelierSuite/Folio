import Planner
import SwiftUI

struct AgendaReminderRow: View {
    @Environment(CalendarStore.self) private var store
    let reminder: ReminderItem

    var body: some View {
        HStack(spacing: 12) {
            Button {
                Task {
                    try? await store.setCompleted(!reminder.isCompleted, for: reminder)
                }
            } label: {
                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(reminder.color.color)
            }
            .buttonStyle(.plain)
            .disabled(reminder.isReadOnly)
            .accessibilityLabel(String(
                localized: reminder.isCompleted ? "Reminder.MarkIncomplete" : "Reminder.MarkCompleted",
                table: "Agenda"
            ))
            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.title)
                    .strikethrough(reminder.isCompleted)
                    .foregroundStyle(reminder.isCompleted ? .secondary : .primary)
                if reminder.hasDueTime, let dueDate = reminder.dueDate {
                    Text(dueDate, format: .dateTime.hour().minute())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
