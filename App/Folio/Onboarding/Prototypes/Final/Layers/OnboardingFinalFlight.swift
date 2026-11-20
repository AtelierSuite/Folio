import SwiftUI

struct OnboardingFinalLaunchSequence {
    var launchedCount = 0
    var landedCount = 0

    func isLaunched(_ rank: Int) -> Bool { rank < launchedCount }
    func isLanded(_ rank: Int) -> Bool { rank < landedCount }

    static func play(count: Int, into sequence: Binding<OnboardingFinalLaunchSequence>, reducesMotion: Bool) async {
        guard !reducesMotion else {
            sequence.wrappedValue = OnboardingFinalLaunchSequence(launchedCount: count, landedCount: count)
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
}

extension View {
    func onboardingFinalFlight(from seed: CGRect, to rest: CGRect, isLanded: Bool) -> some View {
        self
            .scaleEffect(isLanded ? 1 : 0.3)
            .onboardingFinalPlaced(in: isLanded ? rest : seed)
    }

    func onboardingFinalReveal(_ isLanded: Bool, opacity: Double) -> some View {
        self
            .opacity(isLanded ? opacity : 0)
            .animation(.easeOut(duration: 0.3).delay(0.45), value: isLanded)
    }

    func onboardingFinalPlaced(in frame: CGRect) -> some View {
        self
            .frame(width: frame.width, height: frame.height)
            .offset(x: frame.minX, y: frame.minY)
    }
}
