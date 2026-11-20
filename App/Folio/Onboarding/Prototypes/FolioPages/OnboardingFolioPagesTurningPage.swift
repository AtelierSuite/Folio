import SwiftUI

struct OnboardingFolioPagesTurningPage: View {
    let step: OnboardingStep
    let features: [OnboardingFeature]
    let progress: Double

    var body: some View {
        OnboardingFolioPagesPage(step: step, features: features, animates: false, inkDelay: 0)
            .overlay { shading }
            .rotation3DEffect(
                .degrees(-progress * 90),
                axis: (x: 0.04, y: 1, z: 0),
                anchor: .leading,
                perspective: 0.22
            )
            .opacity(progress > 0.65 ? (1 - progress) / 0.35 : 1)
    }

    private var shading: some View {
        LinearGradient(
            stops: [
                .init(color: .black.opacity(0.05 * progress), location: 0),
                .init(color: .white.opacity(0.18 * sin(progress * .pi)), location: 0.55),
                .init(color: .black.opacity(0.45 * progress), location: 1)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .clipShape(OnboardingFolioPagesPaper.shape)
    }
}
