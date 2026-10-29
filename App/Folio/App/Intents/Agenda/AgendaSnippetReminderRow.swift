import Planner
import SwiftUI

struct AgendaSnippetReminderRow: View {
    let reminder: ReminderItem

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "circle")
                .foregroundStyle(reminder.color.color)
            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.title)
                    .font(.subheadline)
                    .lineLimit(2)
                if reminder.hasDueTime, let dueDate = reminder.dueDate {
                    Text(dueDate, style: .time)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
        }
    }
}
