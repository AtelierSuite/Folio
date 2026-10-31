import Planner
import SwiftUI

struct AgendaReminderRow: View {
    @Environment(UndoCoordinator.self) private var undoCoordinator
    let reminder: ReminderItem
    var showsDueDay = false
    let onOpen: () -> Void
    @State private var pendingCompletion: Bool?

    private var isCompleted: Bool {
        pendingCompletion ?? reminder.isCompleted
    }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: toggleCompletion) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(reminder.color.color)
            }
            .buttonStyle(.plain)
            .disabled(reminder.isReadOnly)
            .accessibilityLabel(String(
                localized: isCompleted ? "Reminder.MarkIncomplete" : "Reminder.MarkCompleted",
                table: "Agenda"
            ))
            Button(action: onOpen) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(reminder.title)
                            .strikethrough(isCompleted)
                            .foregroundStyle(isCompleted ? .secondary : .primary)
                        if reminder.isCarriedForward && !isCompleted {
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
        .onChange(of: reminder) {
            pendingCompletion = nil
        }
    }

    private func toggleCompletion() {
        let target = !isCompleted
        pendingCompletion = target
        Task {
            do {
                try await undoCoordinator.setCompleted(target, for: reminder)
            } catch {
                pendingCompletion = nil
            }
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
        showsDueDay && !isCompleted && dueDate < .now
    }
}
