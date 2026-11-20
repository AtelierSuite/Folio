import SwiftUI

struct OnboardingColorFieldsButton: View {
    @Environment(\.colorScheme) private var colorScheme
    let context: OnboardingPrototypeContext

    var body: some View {
        Button(action: context.advance) {
            Text(context.buttonTitle)
                .contentTransition(.opacity)
        }
        .buttonStyle(OnboardingColorFieldsButtonStyle(
            labelColor: OnboardingColorFieldsPalette(step: context.step)
                .buttonLabelColor(deepened: colorScheme == .dark)
        ))
        .keyboardShortcut(.defaultAction)
        .accessibilityIdentifier(context.buttonIdentifier)
    }
}

private struct OnboardingColorFieldsButtonStyle: ButtonStyle {
    let labelColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Metrics.font)
            .foregroundStyle(labelColor)
            .frame(maxWidth: .infinity, minHeight: Metrics.height)
            .background(.white.opacity(configuration.isPressed ? 0.78 : 0.96), in: .capsule)
            .overlay {
                Capsule().strokeBorder(.white.opacity(0.5), lineWidth: 1)
            }
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
