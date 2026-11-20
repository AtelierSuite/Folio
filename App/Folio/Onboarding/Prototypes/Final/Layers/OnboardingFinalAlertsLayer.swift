import SwiftUI

struct OnboardingFinalAlertsLayer: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var isBannerLaunched = false
    @State private var isBannerLanded = false
    let geometry: OnboardingFinalTimelineGeometry
    let source: CGPoint
    let state: OnboardingFinalLayerState
    @Binding var nowHour: Double

    private static let bannerHeight: CGFloat = 50

    var body: some View {
        ZStack(alignment: .topLeading) {
            if isBannerLaunched {
                OnboardingFinalAlertBanner(isLanded: isBannerLanded)
                    .onboardingFinalFlight(
                        from: OnboardingFinalTimelineGeometry.seedFrame(at: source),
                        to: CGRect(x: 12, y: 10, width: geometry.size.width - 24, height: Self.bannerHeight),
                        isLanded: isBannerLanded
                    )
            }
        }
        .task(id: state) { await playAlerts() }
    }

    private var alertHour: Double {
        OnboardingFinalEvent.samples[OnboardingFinalEvent.alertedIndex].start - 0.4
    }

    private func playAlerts() async {
        guard state == .current else {
            await settle()
            return
        }
        guard !reducesMotion else {
            nowHour = alertHour
            isBannerLaunched = true
            isBannerLanded = true
            return
        }
        do {
            try await Task.sleep(for: .seconds(0.6))
            while !Task.isCancelled {
                withAnimation(.smooth(duration: 1.1)) { nowHour = 1.2 }
                try await Task.sleep(for: .seconds(1.2))
                withAnimation(.smooth(duration: 1.3)) { nowHour = alertHour }
                try await Task.sleep(for: .seconds(1.3))
                isBannerLaunched = true
                try await Task.sleep(for: .milliseconds(40))
                withAnimation(.smooth(duration: 0.8, extraBounce: 0.12)) { isBannerLanded = true }
                try await Task.sleep(for: .seconds(2.6))
                withAnimation(.smooth(duration: 0.7)) { isBannerLanded = false }
                try await Task.sleep(for: .seconds(0.7))
                isBannerLaunched = false
                try await Task.sleep(for: .seconds(0.6))
            }
        } catch {
            await settle()
        }
    }

    private func settle() async {
        withAnimation(.smooth(duration: 0.5)) {
            isBannerLanded = false
            nowHour = OnboardingFinalTimelineGrid.restingNowHour
        }
        try? await Task.sleep(for: .seconds(0.5))
        isBannerLaunched = false
    }
}

private struct OnboardingFinalAlertBanner: View {
    let isLanded: Bool

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
        .onboardingFinalReveal(isLanded, opacity: 1)
        .clipShape(shape)
        .glassEffect(.regular.tint(.white.opacity(0.2)), in: shape)
    }
}
