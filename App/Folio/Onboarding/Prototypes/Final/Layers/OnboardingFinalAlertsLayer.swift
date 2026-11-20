import SwiftUI

struct OnboardingFinalAlertsLayer: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var hasBudded = false
    @State private var isBannerShown = false
    @State private var ringCount = 0
    let geometry: OnboardingFinalTimelineGeometry
    let state: OnboardingFinalLayerState

    private static let bellDiameter: CGFloat = 26

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(OnboardingFinalEvent.samples) { event in
                bell(for: event)
            }
            OnboardingFinalAlertBanner(width: geometry.size.width - 24)
                .opacity(isBannerShown ? 1 : 0)
                .offset(x: 12, y: isBannerShown ? 10 : -70)
        }
        .onAppear { hasBudded = true }
        .task(id: state) { await flashBanners() }
    }

    private func bell(for event: OnboardingFinalEvent) -> some View {
        let frame = geometry.eventFrame(event)
        let isRinging = event.id == OnboardingFinalEvent.alertedIndex && isBannerShown
        let restingX = frame.minX - 8
        let restingY = frame.minY - 10
        let buddingX = frame.minX + 10
        let buddingY = frame.minY + 6
        return Image(systemName: "bell.fill")
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(.red)
            .symbolEffect(.wiggle, value: event.id == OnboardingFinalEvent.alertedIndex ? ringCount : 0)
            .opacity(hasBudded ? state.contentOpacity : 0)
            .frame(width: Self.bellDiameter, height: Self.bellDiameter)
            .glassEffect(.regular.tint(.white.opacity(state == .current ? 0.7 : 0.4)), in: .circle)
            .scaleEffect(isRinging ? 1.25 : 1)
            .offset(x: hasBudded ? restingX : buddingX, y: hasBudded ? restingY : buddingY)
            .animation(
                reducesMotion ? nil : .spring(duration: 0.6, bounce: 0.5).delay(0.3 + Double(event.id) * 0.18),
                value: hasBudded
            )
            .animation(.spring(duration: 0.4, bounce: 0.5), value: isRinging)
    }

    private func flashBanners() async {
        guard state == .current, !reducesMotion else {
            isBannerShown = false
            return
        }
        do {
            try await Task.sleep(for: .seconds(1.3))
            while !Task.isCancelled {
                withAnimation(.spring(duration: 0.6, bounce: 0.3)) { isBannerShown = true }
                ringCount += 1
                try await Task.sleep(for: .seconds(2.4))
                withAnimation(.smooth(duration: 0.45)) { isBannerShown = false }
                try await Task.sleep(for: .seconds(1.6))
            }
        } catch {
            withAnimation(.smooth(duration: 0.3)) { isBannerShown = false }
        }
    }
}

private struct OnboardingFinalAlertBanner: View {
    let width: CGFloat

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
                Capsule().fill(.white).frame(width: width * 0.42, height: 6)
                Capsule().fill(.white.opacity(0.65)).frame(width: width * 0.6, height: 5)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .frame(width: width, height: 50)
        .glassEffect(.regular.tint(.white.opacity(0.15)), in: shape)
    }
}
