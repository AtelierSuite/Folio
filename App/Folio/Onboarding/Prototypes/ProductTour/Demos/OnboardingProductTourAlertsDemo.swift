import SwiftUI

struct OnboardingProductTourAlertsDemo: View {
    private static let beats: [OnboardingProductTourBeat] = [
        OnboardingProductTourBeat(.milliseconds(1000), .easeInOut(duration: 0.8)),
        OnboardingProductTourBeat(.milliseconds(900), .spring(duration: 0.6, bounce: 0.35))
    ]

    var body: some View {
        OnboardingProductTourDemo(beats: Self.beats, hold: .seconds(3)) { phase, canvas in
            OnboardingProductTourAlertsScene(phase: phase, canvas: canvas)
        }
    }
}

private struct OnboardingProductTourAlertsScene: View {
    private static let topHour = 8.0
    private static let event = OnboardingProductTourEvent(start: 9.75, duration: 1, color: .teal)
    private static let background: [OnboardingProductTourEvent] = [
        OnboardingProductTourEvent(start: 8.25, duration: 0.75, color: .purple),
        OnboardingProductTourEvent(start: 11.5, duration: 1.25, color: .orange)
    ]
    let phase: Int
    let canvas: OnboardingProductTourCanvas

    var body: some View {
        let metrics = canvas.timelineMetrics(firstHour: 7)
        let isLocked = phase >= 1
        ZStack(alignment: .topLeading) {
            OnboardingProductTourAppScreen {
                OnboardingProductTourTimeline(metrics: metrics, lastHour: 20, topHour: Self.topHour) {
                    ForEach(Array(Self.background.enumerated()), id: \.offset) { _, event in
                        OnboardingProductTourEventBlock(color: event.color)
                            .onboardingProductTourPlaced(in: metrics.frame(for: event))
                    }
                    OnboardingProductTourNowLine(metrics: metrics, hour: 9.2)
                }
            }
            LinearGradient(
                colors: [Color(red: 0.2, green: 0.16, blue: 0.42), Color(red: 0.03, green: 0.03, blue: 0.09)],
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(isLocked ? 0.95 : 0)
            OnboardingProductTourLockClock(width: canvas.size.width)
                .position(x: canvas.size.width / 2, y: canvas.size.height * 0.2)
                .opacity(isLocked ? 1 : 0)
                .offset(y: isLocked ? 0 : -12)
            OnboardingProductTourEventBlock(color: Self.event.color, isFloating: isLocked)
                .onboardingProductTourPlaced(in: isLocked ? lockCardRect : canvas.screenRect(
                    metrics.frame(for: Self.event),
                    metrics: metrics,
                    topHour: Self.topHour
                ))
            OnboardingProductTourBanner()
                .onboardingProductTourPlaced(in: bannerRect)
                .opacity(phase >= 2 ? 1 : 0)
        }
        .environment(\.colorScheme, isLocked ? .dark : colorScheme)
    }

    @Environment(\.colorScheme) private var colorScheme

    private var lockCardRect: CGRect {
        let height = max(36, canvas.size.height * 0.13)
        return CGRect(x: 14, y: canvas.size.height * 0.62, width: canvas.size.width - 28, height: height)
    }

    private var bannerRect: CGRect {
        let height = max(34, canvas.size.height * 0.12)
        let restingY = lockCardRect.minY - 8 - height
        return CGRect(x: 8, y: phase >= 2 ? restingY : -height - 4, width: canvas.size.width - 16, height: height)
    }
}

private struct OnboardingProductTourLockClock: View {
    let width: CGFloat

    var body: some View {
        VStack(spacing: 5) {
            Capsule()
                .fill(.white.opacity(0.6))
                .frame(width: width * 0.28, height: 4)
            RoundedRectangle(cornerRadius: 7)
                .fill(.white.opacity(0.9))
                .frame(width: width * 0.48, height: max(16, width * 0.12))
        }
    }
}

private struct OnboardingProductTourBanner: View {
    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 7) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(LinearGradient(colors: [.pink, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 18, height: 18)
                VStack(alignment: .leading, spacing: 4) {
                    Capsule()
                        .fill(.white.opacity(0.9))
                        .frame(width: proxy.size.width * 0.35, height: 4)
                    Capsule()
                        .fill(.white.opacity(0.5))
                        .frame(width: proxy.size.width * 0.5, height: 3)
                }
                Spacer(minLength: 0)
                Capsule()
                    .fill(.white.opacity(0.4))
                    .frame(width: 10, height: 3)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 9)
            }
            .padding(.horizontal, 8)
            .frame(maxHeight: .infinity)
            .background(.regularMaterial, in: .rect(cornerRadius: 12))
            .shadow(color: .black.opacity(0.3), radius: 6, y: 3)
        }
    }
}
