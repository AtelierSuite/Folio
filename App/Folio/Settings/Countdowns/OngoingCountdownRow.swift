import Planner
import SwiftUI

struct OngoingCountdownRow: View {
    let countdown: RunningCountdown
    let dismiss: () -> Void

    private var state: EventCountdownAttributes.ContentState {
        countdown.state
    }

    private var timeRange: String {
        guard let endDate = state.endDate else {
            return state.startDate.formatted(date: .omitted, time: .shortened)
        }
        return (state.startDate..<endDate).formatted(.interval.hour().minute())
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(state.color.color)
                .frame(width: 10, height: 10)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(state.title)
                    .lineLimit(2)
                Text(timeRange)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            Button(
                String(localized: "Settings.Ongoing.Dismiss", table: "Countdown"),
                systemImage: "xmark.circle.fill",
                action: dismiss
            )
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)
            .accessibilityIdentifier("OngoingCountdown.Dismiss.\(state.title)")
        }
    }
}
