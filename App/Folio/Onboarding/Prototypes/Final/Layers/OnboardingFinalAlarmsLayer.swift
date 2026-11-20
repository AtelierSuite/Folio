import SwiftUI

struct OnboardingFinalAlarmsLayer: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var sequence = OnboardingFinalLaunchSequence()
    @State private var ringCount = 0
    let geometry: OnboardingFinalTimelineGeometry
    let source: CGPoint
    let state: OnboardingFinalLayerState

    private static let wakeHour = 0.55
    private static let height: CGFloat = 32

    var body: some View {
        ZStack(alignment: .topLeading) {
            if sequence.isLaunched(0) {
                OnboardingFinalAlarmPiece(isLanded: sequence.isLanded(0), ringCount: ringCount, state: state)
                    .onboardingFinalFlight(
                        from: OnboardingFinalTimelineGeometry.seedFrame(at: source),
                        to: restingFrame,
                        isLanded: sequence.isLanded(0)
                    )
            }
        }
        .task(id: state) {
            await OnboardingFinalLaunchSequence.follow(
                state,
                count: 1,
                sequence: $sequence,
                reducesMotion: reducesMotion
            )
            guard state == .current, !reducesMotion else { return }
            try? await Task.sleep(for: .seconds(0.6))
            while !Task.isCancelled {
                ringCount += 1
                try? await Task.sleep(for: .seconds(1.8))
            }
        }
    }

    private var restingFrame: CGRect {
        CGRect(
            x: geometry.contentMinX + 6,
            y: geometry.yPosition(Self.wakeHour) - Self.height / 2,
            width: geometry.contentWidth - 6,
            height: Self.height
        )
    }
}

private struct OnboardingFinalAlarmPiece: View {
    let isLanded: Bool
    let ringCount: Int
    let state: OnboardingFinalLayerState

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 10)
        HStack(spacing: 8) {
            Image(systemName: "alarm.fill")
                .font(.system(size: 14, weight: .bold))
                .symbolEffect(.wiggle, value: ringCount)
            Capsule().fill(.white.opacity(0.9)).frame(width: 70, height: 6)
            Spacer(minLength: 0)
            Capsule().fill(.white.opacity(0.6)).frame(width: 34, height: 6)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onboardingFinalReveal(isLanded, opacity: state.contentOpacity)
        .clipShape(shape)
        .glassEffect(.regular.tint(Color.orange.opacity(state.tintOpacity)), in: shape)
        .animation(.easeInOut(duration: 0.6), value: state)
    }
}
