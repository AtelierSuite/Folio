import SwiftUI

struct OnboardingButton: View {
    let context: OnboardingContext

    var body: some View {
        Button(action: context.advance) {
            Text(context.buttonTitle)
                .font(OnboardingButtonMetrics.font)
                .foregroundStyle(.white)
                .contentTransition(.opacity)
        }
        .buttonStyle(.glass)
        #if !os(macOS)
        .buttonBorderShape(.capsule)
        .controlSize(.extraLarge)
        .buttonSizing(.flexible)
        #endif
        .keyboardShortcut(.defaultAction)
        .accessibilityIdentifier(context.buttonIdentifier)
    }
}

private enum OnboardingButtonMetrics {
    #if os(macOS)
    static let font: Font = .body.weight(.semibold)
    #else
    static let font: Font = .headline.weight(.bold)
    #endif
}
