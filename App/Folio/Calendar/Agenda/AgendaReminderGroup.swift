import Planner
import SwiftUI

struct AgendaReminderGroup: View {
    @Environment(\.displayScale) private var displayScale
    @ScaledMetric(relativeTo: .title3) private var checkboxWidth: CGFloat = 22
    let reminders: [ReminderItem]
    let onOpen: (ReminderItem) -> Void

    private static let horizontalPadding: CGFloat = 12
    private static let checkboxSpacing: CGFloat = 12

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(reminders) { reminder in
                AgendaReminderRow(reminder: reminder) { onOpen(reminder) }
                    .padding(.horizontal, Self.horizontalPadding)
                    .padding(.vertical, 10)
                    .overlay(alignment: .bottom) {
                        if reminder.id != reminders.last?.id {
                            AgendaRowDivider(leadingInset: dividerLeadingInset)
                        }
                    }
            }
        }
        .overlay {
            shape.strokeBorder(.separator, lineWidth: 2 / displayScale)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var dividerLeadingInset: CGFloat {
        Self.horizontalPadding + checkboxWidth + Self.checkboxSpacing
    }
}
