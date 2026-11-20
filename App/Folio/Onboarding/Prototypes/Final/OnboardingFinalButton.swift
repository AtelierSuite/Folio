import SwiftUI

struct OnboardingFinalButton: View {
    @Environment(\.colorScheme) private var colorScheme
    let context: OnboardingPrototypeContext

    var body: some View {
        Button(action: context.advance) {
            Text(context.buttonTitle)
                .contentTransition(.opacity)
        }
        .buttonStyle(OnboardingFinalButtonStyle(
            labelColor: OnboardingFinalPalette.buttonLabelColor(for: context.step, deepened: colorScheme == .dark)
        ))
        .keyboardShortcut(.defaultAction)
        .accessibilityIdentifier(context.buttonIdentifier)
    }
}

private struct OnboardingFinalButtonStyle: ButtonStyle {
    let labelColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Metrics.font)
            .foregroundStyle(labelColor)
            .frame(maxWidth: .infinity, minHeight: Metrics.height)
            .background(.white.opacity(configuration.isPressed ? 0.78 : 0.96), in: .capsule)
            .shadow(color: .black.opacity(0.18), radius: 16, y: 8)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(duration: 0.25), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.9), value: labelColor)
            .contentShape(.capsule)
    }

    private enum Metrics {
        #if os(macOS)
        static let height: CGFloat = 36
        static let font: Font = .body.weight(.semibold)
        #else
        static let height: CGFloat = 56
        static let font: Font = .headline.weight(.bold)
        #endif
    }
}
