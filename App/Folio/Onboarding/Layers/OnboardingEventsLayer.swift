import SwiftUI

struct OnboardingEventsLayer: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var sequence = OnboardingLaunchSequence()
    let geometry: OnboardingTimelineGeometry
    let source: CGPoint
    let state: OnboardingLayerState
    let isSharingRow: Bool

    var body: some View {
        let events = OnboardingEvent.samples
        ZStack(alignment: .topLeading) {
            ForEach(events) { event in
                let rank = events.count - 1 - event.id
                if sequence.isLaunched(rank) {
                    OnboardingEventPiece(event: event, isLanded: sequence.isLanded(rank), state: state)
                        .onboardingFlight(
                            from: OnboardingTimelineGeometry.seedFrame(at: source),
                            to: geometry.eventFrame(event, isSharingRow: isSharingRow),
                            isLanded: sequence.isLanded(rank)
                        )
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
        }
    }
}

struct OnboardingEventPiece: View {
    let event: OnboardingEvent
    let isLanded: Bool
    let state: OnboardingLayerState

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
        .onboardingReveal(isLanded, opacity: state.contentOpacity)
        .clipShape(shape)
        .glassEffect(.regular.tint(event.color.opacity(state.tintOpacity)), in: shape)
        .animation(.easeInOut(duration: 0.6), value: state)
    }
}
