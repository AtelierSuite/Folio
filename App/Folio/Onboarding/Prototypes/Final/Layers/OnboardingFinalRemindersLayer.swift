import SwiftUI

struct OnboardingFinalRemindersLayer: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var hasBudded = false
    @State private var isChecked = false
    let geometry: OnboardingFinalTimelineGeometry
    let state: OnboardingFinalLayerState

    private static let checkedIndex = 1

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(OnboardingFinalEvent.samples) { event in
                chip(for: event)
            }
        }
        .task {
            guard !reducesMotion else {
                hasBudded = true
                isChecked = true
                return
            }
            hasBudded = true
            try? await Task.sleep(for: .seconds(1.7))
            withAnimation(.spring(duration: 0.45, bounce: 0.4)) { isChecked = true }
        }
    }

    private func chip(for event: OnboardingFinalEvent) -> some View {
        let eventFrame = geometry.eventFrame(event)
        let chipY = eventFrame.minY + 4
        let budFrame = CGRect(x: eventFrame.maxX - 34, y: chipY, width: 30, height: 28)
        let restingFrame = CGRect(
            x: geometry.remindersMinX,
            y: chipY,
            width: geometry.contentMaxX - geometry.remindersMinX,
            height: 28
        )
        let checked = isChecked && event.id == Self.checkedIndex
        return OnboardingFinalReminderPiece(isChecked: checked, isRevealed: hasBudded, state: state)
            .onboardingFinalPlaced(in: hasBudded ? restingFrame : budFrame)
            .animation(
                reducesMotion ? nil : .spring(duration: 0.8, bounce: 0.35).delay(0.3 + Double(event.id) * 0.2),
                value: hasBudded
            )
    }
}

private struct OnboardingFinalReminderPiece: View {
    let isChecked: Bool
    let isRevealed: Bool
    let state: OnboardingFinalLayerState

    var body: some View {
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
        .opacity(isRevealed ? state.contentOpacity : 0)
        .clipShape(.capsule)
        .glassEffect(.regular.tint(Color.teal.opacity(state.tintOpacity)), in: .capsule)
        .scaleEffect(isChecked ? 0.96 : 1)
        .animation(.easeInOut(duration: 0.6), value: state)
    }
}
