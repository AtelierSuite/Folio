import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: page.systemImage)
                .font(.system(size: 64, weight: .regular))
                .foregroundStyle(.tint)
                .symbolRenderingMode(.hierarchical)
                .frame(height: 88)
            Text(page.title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text(page.description)
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: 520)
        .accessibilityElement(children: .combine)
    }
}
