import SwiftUI

struct OnboardingTimelineCardsView: View {
    let context: OnboardingPrototypeContext

    var body: some View {
        Group {
            switch context.step {
            case .welcome:
                OnboardingWelcomePage(features: context.features, onContinue: context.advance)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            case .setup(let setupStep):
                OnboardingSetupPage(step: setupStep, onSetUp: context.advance)
                    .id(setupStep)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
        .animation(.smooth(duration: 0.45), value: context.step)
    }
}
