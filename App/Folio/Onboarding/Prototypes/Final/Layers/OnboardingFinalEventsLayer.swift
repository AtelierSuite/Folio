import SwiftUI

struct OnboardingFinalEventsLayer: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var hasLanded = false
    let geometry: OnboardingFinalTimelineGeometry
    let state: OnboardingFinalLayerState

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(OnboardingFinalEvent.samples) { event in
                OnboardingFinalEventPiece(event: event, isRevealed: hasLanded, state: state)
                    .onboardingFinalPlaced(in: hasLanded ? geometry.eventFrame(event) : geometry.seedFrame)
                    .animation(
                        reducesMotion
                            ? nil
                            : .spring(duration: 0.85, bounce: 0.3).delay(0.35 + Double(event.id) * 0.22),
                        value: hasLanded
                    )
            }
        }
        .onAppear { hasLanded = true }
    }
}

struct OnboardingFinalEventPiece: View {
    let event: OnboardingFinalEvent
    let isRevealed: Bool
    let state: OnboardingFinalLayerState

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 10)
        ZStack(alignment: .topLeading) {
            Capsule()
                .fill(.white)
                .frame(width: 4)
                .padding(.vertical, 6)
                .padding(.leading, 6)
            VStack(alignment: .leading, spacing: 5) {
                Capsule().fill(.white).frame(width: 64, height: 6)
                Capsule().fill(.white.opacity(0.6)).frame(width: 40, height: 5)
            }
            .padding(.leading, 17)
            .padding(.top, 9)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .opacity(isRevealed ? state.contentOpacity : 0)
        .clipShape(shape)
        .glassEffect(.regular.tint(event.color.opacity(state.tintOpacity)), in: shape)
        .animation(.easeInOut(duration: 0.6), value: state)
    }
}

extension View {
    func onboardingFinalPlaced(in frame: CGRect) -> some View {
        self
            .frame(width: frame.width, height: frame.height)
            .offset(x: frame.minX, y: frame.minY)
    }
}
