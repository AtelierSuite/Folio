import Planner
import SwiftUI

nonisolated private struct TimelineAllDayPlacementKey: LayoutValueKey {
    static let defaultValue: TimelineAllDayPlacement? = nil
}

extension View {
    func timelineAllDayPlacement(_ placement: TimelineAllDayPlacement) -> some View {
        layoutValue(key: TimelineAllDayPlacementKey.self, value: placement)
    }
}

struct TimelineAllDayLayout: Layout {
    var dayCount: Int
    var laneCount: Int
    var laneHeight: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        CGSize(width: proposal.width ?? 0, height: CGFloat(laneCount) * laneHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let dayWidth = bounds.width / CGFloat(max(dayCount, 1))
        for subview in subviews {
            guard let placement = subview[TimelineAllDayPlacementKey.self] else { continue }
            let origin = CGPoint(
                x: bounds.minX + dayWidth * CGFloat(placement.firstDayIndex),
                y: bounds.minY + CGFloat(placement.lane) * laneHeight
            )
            let size = ProposedViewSize(width: dayWidth * CGFloat(placement.dayCount), height: laneHeight)
            subview.place(at: origin, proposal: size)
        }
    }
}
