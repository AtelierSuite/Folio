import SwiftUI

struct OnboardingView: View {
    @State private var page: OnboardingPage = .welcome
    let onFinish: () -> Void

    var body: some View {
        #if os(macOS)
        VStack(spacing: 0) {
            VStack(spacing: 24) {
                Spacer(minLength: 0)
                pageContent
                Spacer(minLength: 0)
                OnboardingPageIndicator(current: page)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 24)
            Divider()
            OnboardingMacFooter(page: $page, onFinish: onFinish)
        }
        .animation(.default, value: page)
        #else
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
            pageContent
            Spacer()
            OnboardingPageIndicator(current: page)
            OnboardingContinueButton(page: $page, onFinish: onFinish)
        }
        .padding(24)
        .animation(.default, value: page)
        #endif
    }

    private var pageContent: some View {
        OnboardingPageView(page: page)
            .id(page)
            .transition(.opacity)
    }
}
