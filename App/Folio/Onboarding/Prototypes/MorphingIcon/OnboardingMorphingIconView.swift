import SwiftUI

struct OnboardingMorphingIconView: View {
    let context: OnboardingPrototypeContext
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var welcomeFeatureIndex: Int?

    var body: some View {
        OnboardingMorphingIconLayout(context: context, glowColor: face.colors.first ?? .accentColor) {
            OnboardingMorphingIconStage(
                step: context.step,
                face: face,
                features: context.features,
                highlightedFeature: highlightedFeature
            )
            ZStack(alignment: .top) {
                OnboardingMorphingIconCaption(context: context, highlightedFeature: highlightedFeature)
                    .id(context.step)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .offset(y: 16)),
                        removal: .opacity
                    ))
            }
        }
        .animation(.spring(duration: 0.55, bounce: 0.2), value: context.step)
        .task(id: context.step == .welcome) { await cycleWelcomeFeatures() }
    }

    private var highlightedFeature: OnboardingFeature? {
        guard context.step == .welcome, let welcomeFeatureIndex,
              context.features.indices.contains(welcomeFeatureIndex) else { return nil }
        return context.features[welcomeFeatureIndex]
    }

    private var face: OnboardingMorphingIconFace {
        if let step = context.currentSetupStep {
            OnboardingMorphingIconFace(step: step)
        } else if let highlightedFeature {
            OnboardingMorphingIconFace(feature: highlightedFeature)
        } else {
            .folio
        }
    }

    private func cycleWelcomeFeatures() async {
        welcomeFeatureIndex = nil
        guard context.step == .welcome, !reducesMotion else { return }
        let sequence: [Int?] = context.features.indices.map { $0 } + [nil]
        while true {
            for index in sequence {
                guard (try? await Task.sleep(for: .seconds(2.2))) != nil else { return }
                welcomeFeatureIndex = index
            }
        }
    }
}
