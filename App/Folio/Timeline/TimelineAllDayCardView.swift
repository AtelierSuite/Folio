import Planner
import SwiftUI

struct TimelineAllDayCardView: View {
    let placement: TimelineAllDayPlacement

    private var shape: UnevenRoundedRectangle {
        let leadingRadius: CGFloat = placement.continuesFromBefore ? 0 : 4
        let trailingRadius: CGFloat = placement.continuesAfter ? 0 : 4
        return UnevenRoundedRectangle(
            topLeadingRadius: leadingRadius,
            bottomLeadingRadius: leadingRadius,
            bottomTrailingRadius: trailingRadius,
            topTrailingRadius: trailingRadius
        )
    }

    var body: some View {
        TimelineEntryTitleView(entry: placement.entry)
            .font(.caption.weight(.semibold))
            .lineLimit(1)
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(Color(placement.entry.color).opacity(0.3), in: shape)
            .padding(1)
            .accessibilityElement(children: .combine)
    }
}
