import Planner
import SwiftUI

/// The stack is rebuilt when the scroll view is resized: a lazy stack keeps estimating unbuilt
/// pages at the size it last measured, which leaves them off the paging grid.
struct CalendarMonthPageStack: View {
    let months: [Date]
    let pageSize: CGSize
    let calendar: Calendar
    let onSelectDay: (MonthDay) -> Void

    var body: some View {
        LazyHStack(spacing: 0) {
            ForEach(months, id: \.self) { month in
                CalendarMonthPageView(grid: MonthGrid(containing: month, calendar: calendar), onSelectDay: onSelectDay)
                    .containerRelativeFrame([.horizontal, .vertical])
            }
        }
        .scrollTargetLayout()
        .id([pageSize.width, pageSize.height])
    }
}
