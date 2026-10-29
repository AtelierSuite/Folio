import Planner
import SwiftUI

struct TimelineEventCardView: View {
    let placement: TimelineTimedPlacement
    let timeZone: TimeZone
    let hourHeight: CGFloat

    private var entry: TimelineEntry {
        placement.entry
    }

    private var shape: UnevenRoundedRectangle {
        let topRadius: CGFloat = placement.continuesFromPreviousDay ? 0 : 5
        let bottomRadius: CGFloat = placement.continuesToNextDay ? 0 : 5
        return UnevenRoundedRectangle(
            topLeadingRadius: topRadius,
            bottomLeadingRadius: bottomRadius,
            bottomTrailingRadius: bottomRadius,
            topTrailingRadius: topRadius
        )
    }

    var body: some View {
        let color = Color(entry.color)
        VStack(alignment: .leading, spacing: 1) {
            TimelineEntryTitleView(entry: entry)
                .font(.caption.weight(.semibold))
            if CGFloat(placement.endHour - placement.startHour) * hourHeight >= 32 {
                Text(timeDescription)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .lineLimit(1)
        .padding(.leading, 6)
        .padding(.trailing, 3)
        .padding(.vertical, 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(color.opacity(0.22), in: shape)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(color)
                .frame(width: 3)
        }
        .clipShape(shape)
        .padding(1)
        .accessibilityElement(children: .combine)
    }

    private var timeDescription: String {
        let style = Date.FormatStyle(date: .omitted, time: .shortened, timeZone: timeZone)
        guard entry.kind == .event else { return placement.interval.start.formatted(style) }
        return "\(placement.interval.start.formatted(style)) – \(placement.interval.end.formatted(style))"
    }
}
