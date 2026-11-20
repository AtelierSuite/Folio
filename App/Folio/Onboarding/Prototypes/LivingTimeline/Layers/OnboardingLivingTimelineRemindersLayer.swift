import SwiftUI

struct OnboardingLivingTimelineRemindersLayer: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var hasSlotted = false
    @State private var isChecked = false
    let geometry: OnboardingLivingTimelineGeometry
    let state: OnboardingLivingTimelineLayerState

    private static let hours: [Double] = [2.1, 3.9, 5.8]
    private static let checkedIndex = 1

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(Array(Self.hours.enumerated()), id: \.offset) { index, hour in
                chip(index: index, hour: hour)
            }
        }
        .task {
            if reducesMotion {
                hasSlotted = true
                isChecked = true
                return
            }
            hasSlotted = true
            try? await Task.sleep(for: .seconds(1.4))
            withAnimation(.spring(duration: 0.45, bounce: 0.4)) { isChecked = true }
        }
    }

    private func chip(index: Int, hour: Double) -> some View {
        let checked = isChecked && index == Self.checkedIndex
        let width = geometry.contentMaxX - geometry.remindersMinX
        let shape = Capsule()
        return HStack(spacing: 6) {
            Image(systemName: checked ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.orange)
                .contentTransition(.symbolEffect(.replace))
            Capsule()
                .fill(.orange.opacity(checked ? 0.3 : 0.7))
                .frame(height: 5)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(.orange)
                        .frame(height: 1.5)
                        .scaleEffect(x: checked ? 1 : 0, anchor: .leading)
                }
        }
        .padding(.horizontal, 7)
        .frame(width: width, height: 26)
        .background(shape.fill(.orange.opacity(0.14)).background(shape.fill(.background)))
        .livingTimelineOutline(state == .current, shape: shape, color: .orange)
        .scaleEffect(checked ? 0.96 : 1)
        .offset(
            x: geometry.remindersMinX + (hasSlotted ? 0 : 50),
            y: geometry.yPosition(hour) - 13
        )
        .opacity(hasSlotted ? 1 : 0)
        .animation(
            reducesMotion ? nil : .spring(duration: 0.55, bounce: 0.3).delay(0.3 + Double(index) * 0.14),
            value: hasSlotted
        )
    }
}
