import SwiftUI

/// Stacks week rows from the top, each `1 / displayedWeekCount` of the height, so every page
/// shares the row height of the month in view and its rows line up with the pages beside it.
/// Rows past the bottom are left for the page to clip.
struct CalendarMonthWeekRowsLayout: Layout {
    var displayedWeekCount: Double

    var animatableData: Double {
        get { displayedWeekCount }
        set { displayedWeekCount = newValue }
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rowHeight = bounds.height / max(displayedWeekCount, 1)
        for (index, row) in subviews.enumerated() {
            row.place(
                at: CGPoint(x: bounds.minX, y: bounds.minY + rowHeight * CGFloat(index)),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: bounds.width, height: rowHeight)
            )
        }
    }
}
