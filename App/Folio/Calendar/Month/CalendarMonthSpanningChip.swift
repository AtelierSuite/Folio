import Planner
import SwiftUI

struct CalendarMonthSpanningChip: View {
    let item: MonthDayItem

    private let shape = Rectangle()

    var body: some View {
        Text(item.entry.title)
            .font(.caption2.weight(.semibold))
            .lineLimit(1)
            .padding(.horizontal, 3)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .foregroundStyle(Color(item.entry.color))
            .background(Color(item.entry.color).opacity(0.3), in: shape)
            .invitationCardStyle(item.entry.invitationStyle, color: Color(item.entry.color), in: shape)
    }
}
