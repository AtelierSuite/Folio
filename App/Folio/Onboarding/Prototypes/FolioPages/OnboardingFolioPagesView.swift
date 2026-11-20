import SwiftUI

struct OnboardingFolioPagesView: View {
    let context: OnboardingPrototypeContext
    @Environment(\.accessibilityReduceMotion) private var reducesMotion

    var body: some View {
        #if os(macOS)
        VStack(spacing: 0) {
            content
                .padding(.horizontal, 32)
                .padding(.top, 28)
                .padding(.bottom, 24)
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
        .background { OnboardingFolioPagesDesk() }
        #else
        ScrollView {
            content
                .padding(.horizontal, 24)
                .padding(.top, 36)
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
        .background { OnboardingFolioPagesDesk().ignoresSafeArea() }
        #endif
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: OnboardingFolioPagesMetrics.sectionSpacing) {
            OnboardingFolioPagesBook(step: context.step, pageNumber: pageNumber, features: context.features)
                .frame(maxWidth: .infinity)
            OnboardingFolioPagesCaption(step: context.step, features: context.features)
        }
        .animation(reducesMotion ? .easeInOut(duration: 0.2) : .smooth(duration: 0.55), value: context.step)
    }

    private var pageNumber: Int {
        context.currentIndex.map { $0 + 1 } ?? 0
    }

    private var button: some View {
        OnboardingContinueButton(title: context.buttonTitle, action: context.advance)
            .accessibilityIdentifier(context.buttonIdentifier)
    }
}
