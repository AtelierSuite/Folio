import SwiftUI

struct OnboardingAlertsGraphic: View {
    private static let event = OnboardingTimelineSlot(start: 2.4, duration: 1.4)

    var body: some View {
        OnboardingGraphicCard(tint: .orange) {
            OnboardingSequencePlayer(count: 3, interval: .milliseconds(650), hold: .seconds(2.5)) { shownCount in
                OnboardingTimeline { metrics in
                    let eventFrame = metrics.frame(for: Self.event)
                    OnboardingEventBlock(color: .orange)
                        .onboardingPopIn(shownCount > 0)
                        .onboardingPlaced(in: eventFrame)
                    OnboardingAlertLeadLine(isShown: shownCount > 1)
                        .frame(width: 2, height: eventFrame.minY - metrics.y(at: 1.15))
                        .offset(x: eventFrame.midX - 1, y: metrics.y(at: 1.15))
                    OnboardingAlertBanner(isRinging: shownCount > 2)
                        .frame(width: eventFrame.width + 12, height: metrics.y(at: 1.0))
                        .offset(x: eventFrame.minX - 6, y: shownCount > 2 ? metrics.y(at: 0.1) : -metrics.y(at: 1.4))
                        .opacity(shownCount > 2 ? 1 : 0)
                }
            }
        }
    }
}

private struct OnboardingAlertLeadLine: View {
    let isShown: Bool

    var body: some View {
        Rectangle()
            .stroke(.orange, style: StrokeStyle(lineWidth: 2, dash: [3, 4]))
            .scaleEffect(y: isShown ? 1 : 0, anchor: .bottom)
    }
}

private struct OnboardingAlertBanner: View {
    let isRinging: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "bell.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .symbolEffect(.wiggle, value: isRinging)
                .frame(width: 32, height: 32)
                .background(
                    LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom),
                    in: .rect(cornerRadius: 8)
                )
            VStack(alignment: .leading, spacing: 5) {
                Capsule()
                    .fill(.primary.opacity(0.7))
                    .frame(maxWidth: 90, maxHeight: 6)
                Capsule()
                    .fill(.secondary.opacity(0.5))
                    .frame(maxWidth: 130, maxHeight: 5)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .background(.regularMaterial, in: .rect(cornerRadius: 14))
        .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
    }
}
