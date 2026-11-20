import SwiftUI

struct OnboardingProductTourDevice<Screen: View>: View {
    @ViewBuilder let screen: Screen

    #if os(macOS)
    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 12)
        VStack(spacing: 0) {
            OnboardingProductTourTitleBar()
            Divider()
            screen
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .textBackgroundColor))
                .clipped()
        }
        .frame(
            width: OnboardingProductTourMetrics.deviceSize.width,
            height: OnboardingProductTourMetrics.deviceSize.height
        )
        .clipShape(shape)
        .overlay(shape.strokeBorder(Color.primary.opacity(0.15), lineWidth: 1))
        .shadow(color: .black.opacity(0.2), radius: 18, y: 10)
    }
    #else
    var body: some View {
        let bezel = OnboardingProductTourMetrics.bezelWidth
        let size = OnboardingProductTourMetrics.deviceSize
        let screenCorner = OnboardingProductTourMetrics.screenCornerRadius
        let frameShape = RoundedRectangle(cornerRadius: screenCorner + bezel)
        screen
            .frame(width: size.width - bezel * 2, height: size.height - bezel * 2)
            .background(.background)
            .clipShape(.rect(cornerRadius: screenCorner))
            .overlay(alignment: .top) {
                Capsule()
                    .fill(.black)
                    .frame(width: 46, height: 14)
                    .padding(.top, 8)
            }
            .padding(bezel)
            .background(Color(white: 0.09), in: frameShape)
            .overlay(frameShape.strokeBorder(titanium, lineWidth: 1.5))
            .background(alignment: .topLeading) { sideButtons(offset: -1.5, heights: [16, 26, 26], top: 70) }
            .background(alignment: .topTrailing) { sideButtons(offset: 1.5, heights: [40], top: 92) }
            .shadow(color: .black.opacity(0.25), radius: 20, y: 12)
    }

    private var titanium: LinearGradient {
        LinearGradient(
            colors: [Color(white: 0.75), Color(white: 0.35), Color(white: 0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func sideButtons(offset: CGFloat, heights: [CGFloat], top: CGFloat) -> some View {
        VStack(spacing: 8) {
            ForEach(Array(heights.enumerated()), id: \.offset) { _, height in
                Capsule()
                    .fill(Color(white: 0.45))
                    .frame(width: 3, height: height)
            }
        }
        .padding(.top, top)
        .offset(x: offset)
    }
    #endif
}

#if os(macOS)
private struct OnboardingProductTourTitleBar: View {
    var body: some View {
        HStack(spacing: 6) {
            ForEach([Color.red, Color.yellow, Color.green], id: \.self) { color in
                Circle()
                    .fill(color.opacity(0.85))
                    .frame(width: 9, height: 9)
            }
            Spacer(minLength: 0)
            Capsule()
                .fill(Color.secondary.opacity(0.35))
                .frame(width: 60, height: 5)
            Spacer(minLength: 0)
            Color.clear.frame(width: 39, height: 1)
        }
        .padding(.horizontal, 10)
        .frame(height: OnboardingProductTourMetrics.titleBarHeight)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
#endif
