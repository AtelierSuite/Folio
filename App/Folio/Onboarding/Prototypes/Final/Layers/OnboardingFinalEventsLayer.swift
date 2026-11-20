import SwiftUI

struct OnboardingFinalEventsLayer: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var sequence = OnboardingFinalLaunchSequence()
    let geometry: OnboardingFinalTimelineGeometry
    let source: CGPoint
    let state: OnboardingFinalLayerState
    let isSharingRow: Bool

    var body: some View {
        let events = OnboardingFinalEvent.samples
        ZStack(alignment: .topLeading) {
            ForEach(events) { event in
                let rank = events.count - 1 - event.id
                if sequence.isLaunched(rank) {
                    OnboardingFinalEventPiece(event: event, isLanded: sequence.isLanded(rank), state: state)
                        .onboardingFinalFlight(
                            from: OnboardingFinalTimelineGeometry.seedFrame(at: source),
                            to: geometry.eventFrame(event, isSharingRow: isSharingRow),
                            isLanded: sequence.isLanded(rank)
                        )
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
        }
    }
}

struct OnboardingFinalEventPiece: View {
    let event: OnboardingFinalEvent
    let isLanded: Bool
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
        .onboardingFinalReveal(isLanded, opacity: state.contentOpacity)
        .clipShape(shape)
        .glassEffect(.regular.tint(event.color.opacity(state.tintOpacity)), in: shape)
        .animation(.easeInOut(duration: 0.6), value: state)
    }
}
