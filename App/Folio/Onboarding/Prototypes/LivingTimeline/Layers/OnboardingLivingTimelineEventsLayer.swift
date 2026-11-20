import SwiftUI

struct OnboardingLivingTimelineEventsLayer: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var hasLanded = false
    let geometry: OnboardingLivingTimelineGeometry
    let state: OnboardingLivingTimelineLayerState

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(OnboardingLivingTimelineEvent.samples) { event in
                eventBlock(event)
            }
        }
        .onAppear { hasLanded = true }
    }

    private func eventBlock(_ event: OnboardingLivingTimelineEvent) -> some View {
        let frame = geometry.eventFrame(event)
        let shape = RoundedRectangle(cornerRadius: 8)
        return shape
            .fill(event.color.opacity(0.2))
            .background(shape.fill(.background))
            .overlay(alignment: .leading) {
                Rectangle().fill(event.color).frame(width: 4)
            }
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 5) {
                    Capsule().fill(event.color).frame(width: frame.width * 0.55, height: 6)
                    Capsule().fill(event.color.opacity(0.45)).frame(width: frame.width * 0.32, height: 5)
                }
                .padding(.leading, 12)
                .padding(.top, 8)
            }
            .clipShape(shape)
            .livingTimelineOutline(state == .current, shape: shape, color: event.color)
            .frame(width: frame.width, height: frame.height)
            .offset(x: frame.minX, y: hasLanded ? frame.minY : frame.minY - 70)
            .opacity(hasLanded ? 1 : 0)
            .animation(
                reducesMotion ? nil : .spring(duration: 0.6, bounce: 0.35).delay(0.25 + Double(event.id) * 0.18),
                value: hasLanded
            )
    }
}
