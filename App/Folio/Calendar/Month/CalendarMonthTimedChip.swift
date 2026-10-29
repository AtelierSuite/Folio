import Planner
import SwiftUI

struct CalendarMonthTimedChip: View {
    let entry: TimelineEntry

    var body: some View {
        HStack(spacing: 2) {
            if entry.kind == .event {
                Circle()
                    .fill(Color(entry.color))
                    .frame(width: 5, height: 5)
            }
            TimelineEntryTitleView(entry: entry)
                .foregroundStyle(entry.kind == .reminder ? Color(entry.color) : .primary)
        }
        .font(.caption2)
        .lineLimit(1)
        .padding(.horizontal, 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .invitationCardStyle(entry.invitationStyle, color: Color(entry.color), in: RoundedRectangle(cornerRadius: 3))
    }
}
