#if os(iOS)
import Planner
import SwiftUI

struct LeaveByCircularView: View {
    private static let gaugeMinutes = 60.0

    let countdown: LeaveByCountdown

    var body: some View {
        Gauge(value: max(Self.gaugeMinutes - Double(countdown.minutesLeft), 0), in: 0...Self.gaugeMinutes) {
            Image(systemName: countdown.transportSymbol)
        } currentValueLabel: {
            Text(countdown.minutesLeft, format: .number)
        }
        .gaugeStyle(.accessoryCircular)
    }
}

struct LeaveByRectangularView: View {
    let countdown: LeaveByCountdown

    private var headline: String {
        countdown.isOverdue ? countdown.headline : "\(countdown.headline) \(countdown.value)"
    }

    private var detail: String {
        guard countdown.leaveBy.needsUmbrella else { return countdown.travelText }
        return "\(countdown.travelText) · \(String(localized: "LeaveBy.Umbrella", table: "Widgets"))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(verbatim: headline)
                .font(.headline)
            Text(verbatim: countdown.leaveBy.event.title)
                .font(.caption)
            Text(verbatim: detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
#endif
