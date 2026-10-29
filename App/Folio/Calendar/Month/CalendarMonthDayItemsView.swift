import Planner
import SwiftUI

struct CalendarMonthDayItemsView: View {
    @Environment(\.eventActions) private var actions
    @ScaledMetric(relativeTo: .caption2) private var rowHeight: CGFloat = 15
    let items: [MonthDayItem]
    let day: Date

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
                        .eventInteractions(for: item.entry, actions: actions)
                        .calendarMonthDraggable(item.entry, from: day)
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

private extension View {
    @ViewBuilder
    func eventInteractions(for entry: TimelineEntry, actions: EventActions?) -> some View {
        if let actions, let event = actions.event(for: entry) {
            eventInteractions(event, actions: actions, placement: .monthCell)
        } else {
            self
        }
    }
}
