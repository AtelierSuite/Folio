import Planner
import SwiftUI

struct TimelineReminderCheckbox: View {
    @Environment(\.reminderCompletion) private var completion
    let entry: TimelineEntry
    @State private var pendingCompletion: Bool?

    private var isCompleted: Bool {
        pendingCompletion ?? entry.isCompleted
    }

    private var tint: Color {
        entry.isOverdue && !isCompleted ? .red : Color(entry.color)
    }

    var body: some View {
        Button(action: toggle) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(tint)
                .padding(1)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(entry.isReadOnly || completion == nil)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(isCompleted ? .isSelected : [])
        .accessibilityIdentifier("ReminderCheckbox.\(entry.title)")
        .onChange(of: entry) {
            pendingCompletion = nil
        }
    }

    private var accessibilityLabel: String {
        isCompleted
            ? String(localized: "Checkbox.MarkIncomplete \(entry.title)", table: "Reminders")
            : String(localized: "Checkbox.MarkCompleted \(entry.title)", table: "Reminders")
    }

    private func toggle() {
        guard let completion else { return }
        let target = !isCompleted
        pendingCompletion = target
        Task {
            if await !completion.setCompleted(target, entry) {
                pendingCompletion = nil
            }
        }
    }
}
