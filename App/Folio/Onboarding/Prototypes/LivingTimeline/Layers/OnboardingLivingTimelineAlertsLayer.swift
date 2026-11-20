import SwiftUI

struct OnboardingLivingTimelineAlertsLayer: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var hasAttached = false
    @State private var isBannerShown = false
    @State private var ringCount = 0
    let geometry: OnboardingLivingTimelineGeometry
    let state: OnboardingLivingTimelineLayerState

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(OnboardingLivingTimelineEvent.samples) { event in
                bell(for: event)
            }
            OnboardingLivingTimelineAlertBanner(geometry: geometry, isShown: isBannerShown)
        }
        .onAppear { hasAttached = true }
        .task(id: state) { await flashBanners() }
    }

    private func bell(for event: OnboardingLivingTimelineEvent) -> some View {
        let frame = geometry.eventFrame(event)
        let isAlerted = event.id == OnboardingLivingTimelineEvent.alertedIndex
        let isRinging = isAlerted && isBannerShown
        return Image(systemName: "bell.fill")
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white)
            .symbolEffect(.wiggle, value: isAlerted ? ringCount : 0)
            .frame(width: 22, height: 22)
            .background(Circle().fill(.red.gradient))
            .background {
                if isAlerted && state == .current && !reducesMotion {
                    Circle()
                        .stroke(.red, lineWidth: 2)
                        .phaseAnimator([false, true]) { ring, isExpanded in
                            ring
                                .scaleEffect(isExpanded ? 2 : 1)
                                .opacity(isExpanded ? 0 : 0.8)
                        } animation: { isExpanded in
                            isExpanded ? .easeOut(duration: 1.3) : .linear(duration: 0.01)
                        }
                }
            }
            .overlay { Circle().strokeBorder(.background, lineWidth: 2) }
            .scaleEffect(hasAttached ? (isRinging ? 1.3 : 1) : 0.1)
            .opacity(hasAttached ? 1 : 0)
            .offset(x: frame.minX - 11, y: frame.minY - 6)
            .animation(
                reducesMotion ? nil : .spring(duration: 0.45, bounce: 0.5).delay(0.2 + Double(event.id) * 0.15),
                value: hasAttached
            )
            .animation(.spring(duration: 0.4, bounce: 0.5), value: isRinging)
    }

    private func flashBanners() async {
        guard state == .current, !reducesMotion else {
            isBannerShown = false
            return
        }
        do {
            try await Task.sleep(for: .seconds(1.1))
            while !Task.isCancelled {
                withAnimation(.spring(duration: 0.5, bounce: 0.3)) { isBannerShown = true }
                ringCount += 1
                try await Task.sleep(for: .seconds(2.2))
                withAnimation(.smooth(duration: 0.4)) { isBannerShown = false }
                try await Task.sleep(for: .seconds(1.8))
            }
        } catch {
            withAnimation(.smooth(duration: 0.3)) { isBannerShown = false }
        }
    }
}
