import SwiftUI

struct OnboardingCalendarGraphic: View {
    private static let events: [(slot: OnboardingTimelineSlot, color: Color)] = [
        (OnboardingTimelineSlot(start: 0.15, duration: 0.9), .red),
        (OnboardingTimelineSlot(start: 1.25, duration: 1.25, laneCount: 2), .blue),
        (OnboardingTimelineSlot(start: 1.5, duration: 1.4, lane: 1, laneCount: 2), .green),
        (OnboardingTimelineSlot(start: 3.05, duration: 0.85), .orange)
    ]
    private static let nowHour = 2.2

    var body: some View {
        OnboardingGraphicCard(tint: .red) {
            OnboardingSequencePlayer(count: Self.events.count + 1) { shownCount in
                OnboardingTimeline { metrics in
                    ForEach(Array(Self.events.enumerated()), id: \.offset) { index, event in
                        OnboardingEventBlock(color: event.color)
                            .onboardingPopIn(index < shownCount)
                            .onboardingPlaced(in: metrics.frame(for: event.slot))
                    }
                    OnboardingNowLine(isShown: shownCount > Self.events.count)
                        .frame(width: metrics.size.width - OnboardingTimelineMetrics.gutter + 6)
                        .offset(
                            x: OnboardingTimelineMetrics.gutter - 6,
                            y: metrics.y(at: Self.nowHour) - OnboardingNowLine.dotSize / 2
                        )
                }
            }
        }
    }
}

private struct OnboardingNowLine: View {
    static let dotSize: CGFloat = 10
    let isShown: Bool

    var body: some View {
        HStack(spacing: 0) {
            Circle()
                .fill(.red)
                .frame(width: Self.dotSize, height: Self.dotSize)
                .scaleEffect(isShown ? 1 : 0)
            Rectangle()
                .fill(.red)
                .frame(height: 2)
                .scaleEffect(x: isShown ? 1 : 0, anchor: .leading)
        }
        .frame(height: Self.dotSize)
    }
}
