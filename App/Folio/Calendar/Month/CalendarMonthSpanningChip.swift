import Planner
import SwiftUI

struct CalendarMonthSpanningChip: View {
    let item: MonthDayItem

    private var shape: UnevenRoundedRectangle {
        let leadingRadius: CGFloat = item.continuesFromPreviousDay ? 0 : 3
        let trailingRadius: CGFloat = item.continuesToNextDay ? 0 : 3
        return UnevenRoundedRectangle(
            topLeadingRadius: leadingRadius,
            bottomLeadingRadius: leadingRadius,
            bottomTrailingRadius: trailingRadius,
            topTrailingRadius: trailingRadius
        )
    }

    var body: some View {
        Text(item.entry.title)
            .font(.caption2.weight(.semibold))
            .lineLimit(1)
            .padding(.horizontal, 3)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(Color(item.entry.color).opacity(0.3), in: shape)
            .invitationCardStyle(item.entry.invitationStyle, color: Color(item.entry.color), in: shape)
    }
}
