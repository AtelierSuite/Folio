import Planner
import SwiftUI

struct TimelineAllDayCardView: View {
    let placement: TimelineAllDayPlacement

    private let shape = Rectangle()

    var body: some View {
        TimelineEntryTitleView(entry: placement.entry)
            .font(.caption.weight(.semibold))
            .lineLimit(1)
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(Color(placement.entry.color).opacity(0.3), in: shape)
            .invitationCardStyle(placement.entry.invitationStyle, color: Color(placement.entry.color), in: shape)
            .padding(1)
            .accessibilityElement(children: .combine)
    }
}
