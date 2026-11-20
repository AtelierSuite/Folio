import SwiftUI

struct OnboardingProductTourEventBlock: View {
    let color: Color
    var isFloating = false

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: isFloating ? 9 : 5)
        shape
            .fill(color.opacity(isFloating ? 0.35 : 0.2))
            .background(.thinMaterial.opacity(isFloating ? 1 : 0), in: shape)
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(color)
                    .frame(width: 2.5)
            }
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 3) {
                    Capsule()
                        .fill(isFloating ? Color.white : color)
                        .frame(width: 34, height: 3.5)
                    Capsule()
                        .fill((isFloating ? Color.white : color).opacity(0.5))
                        .frame(width: 20, height: 3)
                }
                .padding(.leading, 7)
                .padding(.top, 5)
            }
            .clipShape(shape)
    }
}

struct OnboardingProductTourNavBar: View {
    var body: some View {
        HStack(spacing: 6) {
            Capsule()
                .fill(Color.primary.opacity(0.85))
                .frame(width: 34, height: 6)
            Capsule()
                .fill(Color.secondary.opacity(0.4))
                .frame(width: 16, height: 4)
            Spacer(minLength: 0)
            Circle()
                .fill(Color.secondary.opacity(0.22))
                .frame(width: 11, height: 11)
        }
        .padding(.horizontal, 10)
        .frame(height: OnboardingProductTourMetrics.navBarHeight)
    }
}

struct OnboardingProductTourAppScreen<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            Color.clear
                .frame(height: OnboardingProductTourMetrics.statusBarHeight)
            OnboardingProductTourNavBar()
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct OnboardingProductTourStatusBar: View {
    var body: some View {
        HStack(spacing: 2) {
            Capsule()
                .frame(width: 16, height: 4.5)
            Spacer(minLength: 0)
            Capsule()
                .frame(width: 7, height: 4)
            Capsule()
                .frame(width: 7, height: 4)
            RoundedRectangle(cornerRadius: 1.5)
                .frame(width: 12, height: 5.5)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 20)
        .frame(height: OnboardingProductTourMetrics.statusBarHeight)
    }
}
