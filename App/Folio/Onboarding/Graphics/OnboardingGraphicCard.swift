import SwiftUI

struct OnboardingGraphicCard<Content: View>: View {
    let tint: Color
    var background: AnyShapeStyle = AnyShapeStyle(.background)
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(OnboardingGraphicCardMetrics.padding)
            .frame(maxWidth: .infinity)
            .frame(height: OnboardingGraphicCardMetrics.height)
            .clipShape(shape)
            .background {
                shape
                    .fill(background)
                    .overlay {
                        shape.fill(LinearGradient(
                            colors: [tint.opacity(0.12), tint.opacity(0.03)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    }
                    .shadow(color: tint.opacity(0.18), radius: 18, y: 8)
            }
            .overlay { shape.strokeBorder(tint.opacity(0.18), lineWidth: 1) }
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: OnboardingGraphicCardMetrics.cornerRadius)
    }
}

private enum OnboardingGraphicCardMetrics {
    #if os(macOS)
    static let height: CGFloat = 170
    static let padding: CGFloat = 14
    static let cornerRadius: CGFloat = 20
    #else
    static let height: CGFloat = 210
    static let padding: CGFloat = 18
    static let cornerRadius: CGFloat = 28
    #endif
}
