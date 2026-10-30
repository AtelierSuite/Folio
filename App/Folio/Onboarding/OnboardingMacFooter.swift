#if os(macOS)
import SwiftUI

struct OnboardingMacFooter: View {
    @Binding var page: OnboardingPage
    let onFinish: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            if page.next != nil {
                Button(String(localized: "Action.Skip", table: "Onboarding"), action: onFinish)
                    .buttonStyle(.link)
                    .accessibilityIdentifier("OnboardingSkip")
            }
            Spacer()
            if let previous = page.previous {
                Button(String(localized: "Action.Back", table: "Onboarding")) {
                    page = previous
                }
            }
            OnboardingContinueButton(page: $page, onFinish: onFinish)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}
#endif
