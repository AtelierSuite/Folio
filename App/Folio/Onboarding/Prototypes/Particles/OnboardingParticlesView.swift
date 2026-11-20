import SwiftUI

struct OnboardingParticlesView: View {
    let context: OnboardingPrototypeContext

    var body: some View {
        #if os(macOS)
        VStack(spacing: 0) {
            field
            pageText
                .padding(.horizontal, 32)
                .padding(.top, 8)
                .padding(.bottom, 28)
            Divider()
            HStack {
                Spacer()
                button
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .frame(width: 460)
        .fixedSize(horizontal: false, vertical: true)
        #else
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                field
                pageText
                    .padding(.horizontal, 24)
            }
            .padding(.top, 16)
            .padding(.bottom, 24)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollEdgeEffectStyle(.soft, for: .bottom)
        .safeAreaBar(edge: .bottom, spacing: 0) {
            button
                .frame(maxWidth: 560)
                .padding(24)
        }
        #endif
    }

    private var scene: OnboardingParticlesScene {
        OnboardingParticlesScene.scene(for: context.step, features: context.features)
    }

    private var field: some View {
        OnboardingParticlesField(scene: scene)
            .frame(height: context.step == .welcome ? Metrics.welcomeFieldHeight : Metrics.setupFieldHeight)
            .frame(maxWidth: .infinity)
            .animation(.smooth(duration: 0.8), value: context.step == .welcome)
    }

    private var pageText: some View {
        ZStack(alignment: .topLeading) {
            Group {
                switch context.step {
                case .welcome:
                    OnboardingParticlesWelcomeText(features: context.features)
                case .setup(let setupStep):
                    OnboardingParticlesSetupText(
                        step: setupStep,
                        stepCount: context.plannedSteps.count,
                        currentIndex: context.currentIndex ?? 0,
                        tint: scene.tint
                    )
                }
            }
            .id(context.step)
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .offset(y: 16)).animation(.smooth(duration: 0.5).delay(0.25)),
                removal: .opacity.animation(.easeOut(duration: 0.2))
            ))
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .animation(.smooth(duration: 0.5), value: context.step)
    }

    private var button: some View {
        OnboardingContinueButton(title: context.buttonTitle, action: context.advance)
            .accessibilityIdentifier(context.buttonIdentifier)
    }

    private enum Metrics {
        #if os(macOS)
        static let welcomeFieldHeight: CGFloat = 180
        static let setupFieldHeight: CGFloat = 220
        #else
        static let welcomeFieldHeight: CGFloat = 230
        static let setupFieldHeight: CGFloat = 320
        #endif
    }
}
