import SwiftUI

struct TimelineSlot: Equatable {
    var dayIndex: Int
    var startHour: Double
    var endHour: Double
    var leadingFraction: Double = 0
    var widthFraction: Double = 1
}

nonisolated private struct TimelineSlotKey: LayoutValueKey {
    static let defaultValue: TimelineSlot? = nil
}

extension View {
    func timelineSlot(_ slot: TimelineSlot) -> some View {
        layoutValue(key: TimelineSlotKey.self, value: slot)
    }
}

/// Places each subview by its `timelineSlot`, so the event cards and every layer
/// share one coordinate space and only need a new `hourHeight` to zoom.
struct TimelineSlotLayout: Layout {
    var dayCount: Int
    var hourHeight: CGFloat
    var minimumHeight: CGFloat = 0

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        CGSize(width: proposal.width ?? 0, height: hourHeight * 24)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let dayWidth = bounds.width / CGFloat(max(dayCount, 1))
        for subview in subviews {
            guard let slot = subview[TimelineSlotKey.self] else { continue }
            let width = dayWidth * slot.widthFraction
            let height = max(minimumHeight, CGFloat(slot.endHour - slot.startHour) * hourHeight)
            let origin = CGPoint(
                x: bounds.minX + dayWidth * (CGFloat(slot.dayIndex) + slot.leadingFraction),
                y: bounds.minY + CGFloat(slot.startHour) * hourHeight
            )
            subview.place(at: origin, proposal: ProposedViewSize(width: width, height: height))
        }
    }
}
