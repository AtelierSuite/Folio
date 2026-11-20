import SwiftUI

struct OnboardingRemindersLayer: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var sequence = OnboardingLaunchSequence()
    @State private var isChecked = false
    let geometry: OnboardingTimelineGeometry
    let source: CGPoint
    let state: OnboardingLayerState
    let isSharingRow: Bool

    private static let checkedIndex = 1

    var body: some View {
        let events = OnboardingEvent.samples
        ZStack(alignment: .topLeading) {
            ForEach(events) { event in
                let rank = events.count - 1 - event.id
                if sequence.isLaunched(rank) {
                    chip(for: event, isLanded: sequence.isLanded(rank))
                }
            }
        }
        .task(id: state == .declined) {
            await OnboardingLaunchSequence.follow(
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

    private func chip(for event: OnboardingEvent, isLanded: Bool) -> some View {
        let eventFrame = geometry.eventFrame(event, isSharingRow: isSharingRow)
        let minX = isSharingRow ? geometry.remindersMinX : geometry.contentMinX + 6
        let restingFrame = CGRect(
            x: minX,
            y: eventFrame.minY + 4,
            width: geometry.contentMaxX - minX,
            height: 28
        )
        return OnboardingReminderPiece(
            isChecked: isChecked && event.id == Self.checkedIndex,
            isLanded: isLanded,
            state: state
        )
        .onboardingFlight(
            from: OnboardingTimelineGeometry.seedFrame(at: source),
            to: restingFrame,
            isLanded: isLanded
        )
    }
}

private struct OnboardingReminderPiece: View {
    let isChecked: Bool
    let isLanded: Bool
    let state: OnboardingLayerState

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 8)
        HStack(spacing: 6) {
            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14, weight: .semibold))
                .contentTransition(.symbolEffect(.replace))
            Capsule()
                .fill(.white.opacity(isChecked ? 0.5 : 0.9))
                .frame(height: 5)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onboardingReveal(isLanded, opacity: state.contentOpacity)
        .clipShape(shape)
        .glassEffect(.regular.tint(Color.teal.opacity(state.tintOpacity)), in: shape)
        .animation(.easeInOut(duration: 0.6), value: state)
    }
}
