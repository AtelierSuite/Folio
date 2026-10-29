import Planner
import SwiftUI

struct CalendarMonthDayItemsView: View {
    @ScaledMetric(relativeTo: .caption2) private var rowHeight: CGFloat = 15
    let items: [MonthDayItem]

    private static let spacing: CGFloat = 2

    var body: some View {
        GeometryReader { proxy in
            let capacity = MonthCellOverflow.capacity(
                height: proxy.size.height, rowHeight: rowHeight, spacing: Self.spacing
            )
            let overflow = MonthCellOverflow(itemCount: items.count, capacity: capacity)
            VStack(alignment: .leading, spacing: Self.spacing) {
                ForEach(items.prefix(overflow.visibleCount)) { item in
                    CalendarMonthEntryChip(item: item)
                        .frame(height: rowHeight)
                }
                if overflow.hiddenCount > 0 {
                    CalendarMonthMoreLabel(count: overflow.hiddenCount)
                        .frame(height: rowHeight)
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
}
