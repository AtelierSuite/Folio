import SwiftUI

struct OnboardingContinueButton: View {
    @Binding var page: OnboardingPage
    let onFinish: () -> Void

    var body: some View {
        Button {
            if let next = page.next {
                page = next
            } else {
                onFinish()
            }
        } label: {
            Text(page.next == nil
                ? String(localized: "Action.GetStarted", table: "Onboarding")
                : String(localized: "Action.Continue", table: "Onboarding"))
                #if !os(macOS)
                .frame(maxWidth: 360)
                #endif
        }
        .buttonStyle(.borderedProminent)
        #if !os(macOS)
        .controlSize(.large)
        #endif
        .keyboardShortcut(.defaultAction)
        .accessibilityIdentifier("OnboardingContinue")
    }
}
