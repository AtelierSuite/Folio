import Planner
import SwiftUI

struct AgendaReminderRow: View {
    @Environment(UndoCoordinator.self) private var undoCoordinator
    let reminder: ReminderItem
    var showsDueDay = false
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
                        } else if let dueDateFormat, let dueDate = reminder.dueDate {
                            Text(dueDate, format: dueDateFormat)
                                .font(.subheadline)
                                .foregroundStyle(isOverdue(dueDate) ? AnyShapeStyle(.red) : AnyShapeStyle(.secondary))
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

    private var dueDateFormat: Date.FormatStyle? {
        switch (showsDueDay, reminder.hasDueTime) {
        case (true, true): .dateTime.weekday().month().day().hour().minute()
        case (true, false): .dateTime.weekday().month().day()
        case (false, true): .dateTime.hour().minute()
        case (false, false): nil
        }
    }

    private func isOverdue(_ dueDate: Date) -> Bool {
        showsDueDay && !reminder.isCompleted && dueDate < .now
    }
}
