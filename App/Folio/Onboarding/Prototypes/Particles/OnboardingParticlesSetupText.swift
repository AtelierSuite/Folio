import SwiftUI

struct OnboardingParticlesSetupText: View {
    let step: OnboardingSetupStep
    let stepCount: Int
    let currentIndex: Int
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            OnboardingParticlesProgress(count: stepCount, currentIndex: currentIndex, tint: tint)
            VStack(alignment: .leading, spacing: 8) {
                Text(step.title)
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("OnboardingSetupTitle")
                Text(step.description)
                    .foregroundStyle(.secondary)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct OnboardingParticlesProgress: View {
    let count: Int
    let currentIndex: Int
    let tint: Color

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index <= currentIndex ? AnyShapeStyle(tint) : AnyShapeStyle(.quaternary))
                    .frame(width: index == currentIndex ? 18 : 6, height: 6)
            }
        }
        .accessibilityHidden(true)
    }
}
