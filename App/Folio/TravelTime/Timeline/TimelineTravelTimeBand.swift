import Planner
import SwiftUI

struct TimelineTravelTimeBand: View {
    let estimate: TravelEstimate
    @ScaledMetric(relativeTo: .caption2) private var detailPointSize = TimelineMetrics.cardDetailPointSize

    private let shape = Rectangle()

    var body: some View {
        ViewThatFits(in: .vertical) {
            label
            Color.clear
        }
        .padding(.leading, 6)
        .padding(.trailing, 3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.secondary.opacity(0.12), in: shape)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Color.secondary.opacity(0.5))
                .frame(width: 3)
        }
        .clipShape(shape)
        .padding(.horizontal, 1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(
            format: String(localized: "Accessibility.Label", table: "TravelTime"), duration, estimate.transport.title
        ))
        .accessibilityIdentifier("TravelTime.\(estimate.eventID)")
    }

    private var label: some View {
        HStack(spacing: 2) {
            Image(systemName: estimate.transport.systemImage)
                .imageScale(.small)
            Text(duration)
        }
        .font(.system(size: detailPointSize))
        .foregroundStyle(.secondary)
        .lineLimit(1)
        .padding(.vertical, 1)
    }

    private var duration: String {
        let minutes = max(1, Int((estimate.travelTime / 60).rounded(.up)))
        return Duration.seconds(minutes * 60).formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
    }
}
