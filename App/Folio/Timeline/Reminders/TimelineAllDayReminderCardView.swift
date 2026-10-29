import Planner
import SwiftUI

struct TimelineAllDayReminderCardView: View {
    let placement: TimelineAllDayPlacement
    var onSelect: ((TimelineEntry) -> Void)?

    private var entry: TimelineEntry {
        placement.entry
    }

    var body: some View {
        HStack(spacing: 3) {
            TimelineReminderCheckbox(entry: entry)
            TimelineReminderTitleView(entry: entry)
                .lineLimit(1)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .contentShape(.rect)
                .timelineEntrySelection(entry, onSelect: onSelect)
                .accessibilityLabel(entry.title)
                .accessibilityValue(entry.isOverdue ? String(localized: "Card.Overdue", table: "Reminders") : "")
                .accessibilityHint(String(localized: "Card.OpenHint", table: "Reminders"))
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color(entry.color).opacity(entry.isCompleted ? 0.12 : 0.3), in: RoundedRectangle(cornerRadius: 4))
        .padding(1)
    }
}
