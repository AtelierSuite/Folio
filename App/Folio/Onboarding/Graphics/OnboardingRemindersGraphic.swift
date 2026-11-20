import SwiftUI

struct OnboardingRemindersGraphic: View {
    private static let event = OnboardingTimelineSlot(start: 0.2, duration: 3.6, laneCount: 2)
    private static let reminders: [(slot: OnboardingTimelineSlot, color: Color)] = [
        (OnboardingTimelineSlot(start: 0.25, duration: 0.8, lane: 1, laneCount: 2), .orange),
        (OnboardingTimelineSlot(start: 1.55, duration: 0.8, lane: 1, laneCount: 2), .purple),
        (OnboardingTimelineSlot(start: 2.85, duration: 0.8, lane: 1, laneCount: 2), .blue)
    ]

    var body: some View {
        OnboardingGraphicCard(tint: .orange) {
            OnboardingSequencePlayer(count: Self.reminders.count * 2 + 1, interval: .milliseconds(420)) { shownCount in
                OnboardingTimeline { metrics in
                    OnboardingEventBlock(color: .teal)
                        .onboardingPopIn(shownCount > 0)
                        .onboardingPlaced(in: metrics.frame(for: Self.event))
                    ForEach(Array(Self.reminders.enumerated()), id: \.offset) { index, reminder in
                        OnboardingReminderChip(
                            color: reminder.color,
                            isDone: shownCount > Self.reminders.count + 1 + index
                        )
                        .opacity(shownCount > index + 1 ? 1 : 0)
                        .offset(x: shownCount > index + 1 ? 0 : 24)
                        .onboardingPlaced(in: metrics.frame(for: reminder.slot))
                    }
                }
            }
        }
    }
}

private struct OnboardingReminderChip: View {
    let color: Color
    let isDone: Bool

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .strokeBorder(color, lineWidth: 2.5)
                Circle()
                    .fill(color)
                    .scaleEffect(isDone ? 1 : 0)
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(.white)
                    .scaleEffect(isDone ? 1 : 0)
            }
            .frame(width: 22, height: 22)
            VStack(alignment: .leading, spacing: 4) {
                Capsule()
                    .fill(color.opacity(isDone ? 0.3 : 0.8))
                    .frame(maxWidth: 70, maxHeight: 6)
                Capsule()
                    .fill(color.opacity(isDone ? 0.15 : 0.35))
                    .frame(maxWidth: 44, maxHeight: 5)
            }
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(.background.secondary, in: .rect(cornerRadius: 10))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
    }
}
