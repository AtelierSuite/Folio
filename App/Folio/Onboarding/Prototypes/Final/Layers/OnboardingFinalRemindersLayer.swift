import SwiftUI

struct OnboardingFinalRemindersLayer: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var sequence = OnboardingFinalLaunchSequence()
    @State private var isChecked = false
    let geometry: OnboardingFinalTimelineGeometry
    let source: CGPoint
    let state: OnboardingFinalLayerState
    let isSharingRow: Bool

    private static let checkedIndex = 1

    var body: some View {
        let events = OnboardingFinalEvent.samples
        ZStack(alignment: .topLeading) {
            ForEach(events) { event in
                let rank = events.count - 1 - event.id
                if sequence.isLaunched(rank) {
                    chip(for: event, isLanded: sequence.isLanded(rank))
                }
            }
        }
        .task(id: state == .declined) {
            await OnboardingFinalLaunchSequence.follow(
                state,
                count: events.count,
                sequence: $sequence,
                reducesMotion: reducesMotion
            )
            guard state != .declined, !isChecked else { return }
            guard !reducesMotion else {
                isChecked = true
                return
            }
            try? await Task.sleep(for: .seconds(1))
            withAnimation(.spring(duration: 0.45, bounce: 0.4)) { isChecked = true }
        }
    }

    private func chip(for event: OnboardingFinalEvent, isLanded: Bool) -> some View {
        let eventFrame = geometry.eventFrame(event, isSharingRow: isSharingRow)
        let minX = isSharingRow ? geometry.remindersMinX : geometry.contentMinX + 6
        let restingFrame = CGRect(
            x: minX,
            y: eventFrame.minY + 4,
            width: geometry.contentMaxX - minX,
            height: 28
        )
        return OnboardingFinalReminderPiece(
            isChecked: isChecked && event.id == Self.checkedIndex,
            isLanded: isLanded,
            state: state
        )
        .onboardingFinalFlight(
            from: OnboardingFinalTimelineGeometry.seedFrame(at: source),
            to: restingFrame,
            isLanded: isLanded
        )
    }
}

private struct OnboardingFinalReminderPiece: View {
    let isChecked: Bool
    let isLanded: Bool
    let state: OnboardingFinalLayerState

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 8)
        HStack(spacing: 6) {
            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14, weight: .semibold))
                .contentTransition(.symbolEffect(.replace))
            Capsule()
                .fill(.white.opacity(isChecked ? 0.4 : 0.9))
                .frame(height: 5)
                .overlay {
                    Capsule()
                        .fill(.white)
                        .frame(height: 1.5)
                        .scaleEffect(x: isChecked ? 1 : 0, anchor: .leading)
                }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onboardingFinalReveal(isLanded, opacity: state.contentOpacity)
        .clipShape(shape)
        .glassEffect(.regular.tint(Color.teal.opacity(state.tintOpacity)), in: shape)
        .animation(.easeInOut(duration: 0.6), value: state)
    }
}
