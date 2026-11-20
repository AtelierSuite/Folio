import SwiftUI

struct OnboardingLiquidGlassPageText: View {
    let step: OnboardingStep
    let features: [OnboardingFeature]
    let plannedSteps: [OnboardingSetupStep]

    var body: some View {
        Group {
            switch step {
            case .welcome:
                VStack(alignment: .leading, spacing: Metrics.sectionSpacing) {
                    OnboardingHeader()
                    VStack(alignment: .leading, spacing: Metrics.rowSpacing) {
                        ForEach(features) { feature in
                            OnboardingLiquidGlassFeatureRow(feature: feature)
                        }
                    }
                }
            case .setup(let setupStep):
                VStack(alignment: .leading, spacing: 12) {
                    OnboardingLiquidGlassProgress(
                        count: plannedSteps.count,
                        currentIndex: plannedSteps.firstIndex(of: setupStep) ?? 0
                    )
                    .accessibilityHidden(true)
                    Text(setupStep.title)
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityIdentifier("OnboardingSetupTitle")
                    Text(setupStep.description)
                        .foregroundStyle(.secondary)
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .id(step)
        .transition(.blurReplace)
    }

    private enum Metrics {
        #if os(macOS)
        static let sectionSpacing: CGFloat = 20
        static let rowSpacing: CGFloat = 16
        #else
        static let sectionSpacing: CGFloat = 28
        static let rowSpacing: CGFloat = 22
        #endif
    }
}

struct OnboardingLiquidGlassProgress: View {
    @Namespace private var progressNamespace
    let count: Int
    let currentIndex: Int

    var body: some View {
        GlassEffectContainer(spacing: 6) {
            HStack(spacing: 6) {
                ForEach(0..<count, id: \.self) { index in
                    Capsule()
                        .fill(index <= currentIndex ? Color.accentColor : .clear)
                        .frame(width: index == currentIndex ? 26 : 10, height: 10)
                        .glassEffect(.regular, in: .capsule)
                        .glassEffectID(index, in: progressNamespace)
                }
            }
        }
    }
}

struct OnboardingLiquidGlassFeatureRow: View {
    let feature: OnboardingFeature

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: feature.systemImage)
                .font(.system(size: Metrics.symbolSize, weight: .semibold))
                .foregroundStyle(LinearGradient(
                    colors: feature.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: Metrics.iconSize, height: Metrics.iconSize)
                .glassEffect(.regular.tint(feature.gradientColors[0].opacity(0.2)), in: .circle)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(feature.title)
                    .fontWeight(.bold)
                Text(feature.description)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }

    private enum Metrics {
        #if os(macOS)
        static let symbolSize: CGFloat = 17
        static let iconSize: CGFloat = 40
        #else
        static let symbolSize: CGFloat = 21
        static let iconSize: CGFloat = 50
        #endif
    }
}
