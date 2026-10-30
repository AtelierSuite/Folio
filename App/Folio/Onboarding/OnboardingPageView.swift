import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: Metrics.spacing) {
            Image(systemName: page.systemImage)
                .font(.system(size: Metrics.symbolSize, weight: .regular))
                .foregroundStyle(.tint)
                .symbolRenderingMode(.hierarchical)
                .frame(height: Metrics.symbolSize * 1.4)
            Text(page.title)
                .font(Metrics.titleFont)
                .multilineTextAlignment(.center)
            Text(page.description)
                .font(Metrics.descriptionFont)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        #if !os(macOS)
        .padding(.horizontal, 32)
        #endif
        .frame(maxWidth: 520)
        .accessibilityElement(children: .combine)
    }

    private enum Metrics {
        #if os(macOS)
        static let symbolSize: CGFloat = 52
        static let spacing: CGFloat = 12
        static let titleFont: Font = .title.bold()
        static let descriptionFont: Font = .body
        #else
        static let symbolSize: CGFloat = 64
        static let spacing: CGFloat = 20
        static let titleFont: Font = .largeTitle.bold()
        static let descriptionFont: Font = .title3
        #endif
    }
}
