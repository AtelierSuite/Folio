import SwiftUI

struct OnboardingCarouselIndicator: View {
    let pages: [OnboardingCarouselPage]
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(pages.enumerated()), id: \.element) { index, page in
                let isCurrent = index == currentIndex
                Capsule()
                    .fill(isCurrent ? AnyShapeStyle(page.tint.gradient) : AnyShapeStyle(.quaternary))
                    .frame(width: isCurrent ? 28 : 8, height: 8)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityHidden(true)
    }
}
