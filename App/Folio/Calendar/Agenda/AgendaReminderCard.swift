import Planner
import SwiftUI

struct AgendaReminderCard: View {
    @Environment(\.displayScale) private var displayScale
    let reminder: ReminderItem
    let isFirst: Bool
    let isLast: Bool
    let onOpen: () -> Void

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
    }

    var body: some View {
        AgendaReminderRow(reminder: reminder, onOpen: onOpen)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .overlay {
                shape.strokeBorder(.separator, lineWidth: 2 / displayScale)
            }
            .padding(.horizontal, 16)
            .padding(.top, isFirst ? 8 : 3)
            .padding(.bottom, isLast ? 8 : 3)
    }
}
