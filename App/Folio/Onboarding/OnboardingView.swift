import SwiftUI

struct OnboardingView: View {
    @State private var page: OnboardingPage = .welcome
    let onFinish: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            HStack {
                if let previous = page.previous {
                    Button(String(localized: "Action.Back", table: "Onboarding")) {
                        page = previous
                    }
                }
                Spacer()
                if page.next != nil {
                    Button(String(localized: "Action.Skip", table: "Onboarding"), action: onFinish)
                        .accessibilityIdentifier("OnboardingSkip")
                }
            }
            .buttonStyle(.borderless)
            .frame(minHeight: 32)
            Spacer()
            OnboardingPageView(page: page)
                .id(page)
                .transition(.opacity)
            Spacer()
            OnboardingPageIndicator(current: page)
            continueButton
        }
        .padding(24)
        .animation(.default, value: page)
    }

    private var continueButton: some View {
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
                .frame(maxWidth: 360)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .keyboardShortcut(.defaultAction)
        .accessibilityIdentifier("OnboardingContinue")
    }
}
