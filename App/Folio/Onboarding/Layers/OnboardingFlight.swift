import SwiftUI

struct OnboardingLaunchSequence {
    var launchedCount = 0
    var landedCount = 0

    func isLaunched(_ rank: Int) -> Bool { rank < launchedCount }
    func isLanded(_ rank: Int) -> Bool { rank < landedCount }

    static func play(count: Int, into sequence: Binding<OnboardingLaunchSequence>, reducesMotion: Bool) async {
        guard !reducesMotion else {
            sequence.wrappedValue = OnboardingLaunchSequence(launchedCount: count, landedCount: count)
            return
        }
        try? await Task.sleep(for: .milliseconds(350))
        for rank in 0..<count {
            sequence.wrappedValue.launchedCount = rank + 1
            try? await Task.sleep(for: .milliseconds(40))
            withAnimation(.smooth(duration: 0.85, extraBounce: 0.1)) {
                sequence.wrappedValue.landedCount = rank + 1
            }
            try? await Task.sleep(for: .milliseconds(170))
        }
    }

    static func retract(_ sequence: Binding<OnboardingLaunchSequence>, reducesMotion: Bool) async {
        guard sequence.wrappedValue.launchedCount > 0 else { return }
        if !reducesMotion {
            withAnimation(.smooth(duration: 0.7)) { sequence.wrappedValue.landedCount = 0 }
            try? await Task.sleep(for: .seconds(0.7))
        }
        sequence.wrappedValue = OnboardingLaunchSequence()
    }

    static func follow(
        _ state: OnboardingLayerState,
        count: Int,
        sequence: Binding<OnboardingLaunchSequence>,
        reducesMotion: Bool
    ) async {
        if state == .declined {
            await retract(sequence, reducesMotion: reducesMotion)
        } else if sequence.wrappedValue.launchedCount == 0 {
            await play(count: count, into: sequence, reducesMotion: reducesMotion)
        }
    }
}

extension View {
    func onboardingFlight(from seed: CGRect, to rest: CGRect, isLanded: Bool) -> some View {
        self
            .scaleEffect(isLanded ? 1 : 0.3)
            .onboardingPlaced(in: isLanded ? rest : seed)
    }

    func onboardingReveal(_ isLanded: Bool, opacity: Double) -> some View {
        self
            .opacity(isLanded ? opacity : 0)
            .animation(.easeOut(duration: 0.3).delay(0.45), value: isLanded)
    }

    func onboardingPlaced(in frame: CGRect) -> some View {
        self
            .frame(width: frame.width, height: frame.height)
            .offset(x: frame.minX, y: frame.minY)
    }
}
