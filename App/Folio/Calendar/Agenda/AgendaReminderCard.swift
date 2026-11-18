import Planner
import SwiftUI

struct AgendaReminderCard: View {
    let reminder: ReminderItem
    let isFirst: Bool
    let isLast: Bool
    let onOpen: () -> Void

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
    }

    var body: some View {
        AgendaReminderRow(reminder: reminder, onOpen: onOpen)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(reminder.color.color.opacity(0.08), in: shape)
            .overlay {
                shape.strokeBorder(reminder.color.color.opacity(0.55), lineWidth: 1)
            }
            .padding(.horizontal, 12)
            .padding(.top, isFirst ? 10 : 4)
            .padding(.bottom, isLast ? 10 : 4)
    }
}
