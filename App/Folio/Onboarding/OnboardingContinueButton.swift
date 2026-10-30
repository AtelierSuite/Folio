import SwiftUI

struct OnboardingContinueButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(String(localized: "Action.GetStarted", table: "Onboarding"))
                #if !os(macOS)
                .fontWeight(.bold)
                #endif
        }
        #if os(macOS)
        .buttonStyle(.borderedProminent)
        #else
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.extraLarge)
        .buttonSizing(.flexible)
        #endif
        .keyboardShortcut(.defaultAction)
        .accessibilityIdentifier("OnboardingContinue")
    }
}
