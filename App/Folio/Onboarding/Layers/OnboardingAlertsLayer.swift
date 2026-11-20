import SwiftUI

struct OnboardingAlertsLayer: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var isBannerShown = false
    let geometry: OnboardingTimelineGeometry
    let source: CGPoint
    let state: OnboardingLayerState
    @Binding var nowHour: Double

    private static let bannerHeight: CGFloat = 50

    var body: some View {
        ZStack(alignment: .topLeading) {
            if isBannerShown {
                OnboardingAlertBanner()
                    .onboardingPlaced(
                        in: CGRect(x: 12, y: 10, width: geometry.size.width - 24, height: Self.bannerHeight)
                    )
                    .transition(.offset(y: -14).combined(with: .opacity))
                    .glassEffectTransition(.materialize)
            }
        }
        .task(id: state) { await playAlerts() }
    }

    private var alertHour: Double {
        OnboardingEvent.samples[OnboardingEvent.alertedIndex].start
    }

    private func playAlerts() async {
        guard state == .current else {
            withAnimation(.easeIn(duration: 0.35)) { isBannerShown = false }
            return
        }
        guard !reducesMotion else {
            nowHour = alertHour
            isBannerShown = true
            return
        }
        try? await Task.sleep(for: .seconds(0.5))
        withAnimation(.easeInOut(duration: 2.4)) { nowHour = alertHour }
        try? await Task.sleep(for: .seconds(2.4))
        withAnimation(.easeOut(duration: 0.7)) { isBannerShown = true }
    }
}

private struct OnboardingAlertBanner: View {

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 18)
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 7)
                .fill(LinearGradient(colors: [.pink, .red], startPoint: .top, endPoint: .bottom))
                .frame(width: 28, height: 28)
                .overlay {
                    Image(systemName: "calendar")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                }
            VStack(alignment: .leading, spacing: 6) {
                Capsule().fill(.white).frame(maxWidth: 120, maxHeight: 6)
                Capsule().fill(.white.opacity(0.65)).frame(maxWidth: 180, maxHeight: 5)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 11)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(shape)
        .glassEffect(.regular.tint(.white.opacity(0.2)), in: shape)
    }
}
