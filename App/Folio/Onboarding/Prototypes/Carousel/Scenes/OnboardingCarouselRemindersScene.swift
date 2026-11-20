import SwiftUI

struct OnboardingCarouselRemindersScene: View {
    let isActive: Bool

    var body: some View {
        OnboardingCarouselLoop(
            isActive: isActive,
            count: 6,
            interval: .milliseconds(700),
            hold: .seconds(1.4),
            staticPhase: 5
        ) { phase in
            ZStack {
                OnboardingCarouselReminderList(phase: 0, visibleCount: 3)
                    .frame(width: 210)
                    .opacity(0.5)
                    .scaleEffect(0.86)
                    .rotationEffect(.degrees(7))
                    .offset(x: phase.isMultiple(of: 2) ? 66 : 72, y: -44)
                OnboardingCarouselReminderList(phase: phase, visibleCount: 4)
                    .frame(width: 262)
                    .offset(x: -10, y: 16)
            }
        }
    }
}

private struct OnboardingCarouselReminderList: View {
    private static let widths: [Double] = [0.72, 0.5, 0.88, 0.6, 0.78, 0.46, 0.66]

    let phase: Int
    let visibleCount: Int

    private var removedCount: Int { phase / 2 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Capsule()
                .fill(Color.orange.gradient)
                .frame(width: 96, height: 10)
                .padding(.bottom, 12)
            ForEach(removedCount..<(removedCount + visibleCount), id: \.self) { item in
                OnboardingCarouselReminderRow(
                    isChecked: item == removedCount && !phase.isMultiple(of: 2),
                    widthFraction: Self.widths[item % Self.widths.count]
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
        .padding(16)
        .frame(height: 54 + Double(visibleCount) * 40, alignment: .top)
        .clipShape(.rect(cornerRadius: 20, style: .continuous))
        .onboardingCarouselCard()
    }
}

private struct OnboardingCarouselReminderRow: View {
    let isChecked: Bool
    let widthFraction: Double

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .strokeBorder(.orange, lineWidth: 2)
                Circle()
                    .fill(.orange)
                    .scaleEffect(isChecked ? 1 : 0.01)
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(.white)
                    .scaleEffect(isChecked ? 1 : 0.01)
            }
            .frame(width: 22, height: 22)
            VStack(alignment: .leading, spacing: 5) {
                Capsule()
                    .fill(Color.primary.opacity(isChecked ? 0.2 : 0.6))
                    .frame(width: 150 * widthFraction, height: 7)
                Capsule()
                    .fill(Color.secondary.opacity(0.35))
                    .frame(width: 90 * widthFraction, height: 5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 40)
    }
}
