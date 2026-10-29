import Planner
import SwiftUI

struct AgendaReminderRow: View {
    @Environment(UndoCoordinator.self) private var undoCoordinator
    let reminder: ReminderItem
    let onOpen: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button {
                Task {
                    try? await undoCoordinator.setCompleted(!reminder.isCompleted, for: reminder)
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
            Button(action: onOpen) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(reminder.title)
                            .strikethrough(reminder.isCompleted)
                            .foregroundStyle(reminder.isCompleted ? .secondary : .primary)
                        if reminder.isCarriedForward && !reminder.isCompleted {
                            ReminderOverdueLabel(reminder: reminder)
                        } else if reminder.hasDueTime, let dueDate = reminder.dueDate {
                            Text(dueDate, format: .dateTime.hour().minute())
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer(minLength: 0)
                    if reminder.isReadOnly {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .accessibilityLabel(String(localized: "Event.ReadOnly", table: "Agenda"))
                    }
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
        }
    }
}
