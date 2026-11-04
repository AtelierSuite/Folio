import Planner
import SwiftUI

struct NotificationReminderTaskView: View {
    let title: String
    let reminder: NotificationReminderDetails
    let accentColor: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .strokeBorder(accentColor, lineWidth: 2)
                .frame(width: 24, height: 24)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(titleWithPriority)
                    .font(.title3.bold())
                    .lineLimit(3)
                    .accessibilityIdentifier("NotificationDetail.Title")
                if let notes = reminder.notes {
                    Text(notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .accessibilityIdentifier("NotificationDetail.Notes")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var titleWithPriority: AttributedString {
        guard let marks = reminder.priorityMarks else { return AttributedString(title) }
        var priority = AttributedString("\(marks) ")
        priority.foregroundColor = accentColor
        return priority + AttributedString(title)
    }
}
