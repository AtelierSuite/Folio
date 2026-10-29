import Planner
import SwiftUI

struct ReminderOverdueLabel: View {
    let reminder: ReminderItem

    private var dueDescription: String {
        guard let dueDate = reminder.dueDate else { return "" }
        return reminder.hasDueTime
            ? dueDate.formatted(.dateTime.month(.abbreviated).day().hour().minute())
            : dueDate.formatted(.dateTime.month(.abbreviated).day())
    }

    var body: some View {
        Text(String(localized: "Overdue.Since \(dueDescription)", table: "Reminders"))
            .font(.subheadline)
            .foregroundStyle(.red)
    }
}
