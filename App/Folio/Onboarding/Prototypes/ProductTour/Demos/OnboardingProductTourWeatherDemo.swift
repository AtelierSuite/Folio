import SwiftUI

struct OnboardingProductTourWeatherDemo: View {
    fileprivate static let forecast = [
        "sun.max.fill", "sun.max.fill", "cloud.sun.fill", "cloud.sun.fill",
        "cloud.fill", "cloud.drizzle.fill", "cloud.rain.fill"
    ]
    fileprivate static let shownHours = min(forecast.count, Int(OnboardingProductTourMetrics.visibleHours.rounded(.up)))

    private static let beats: [OnboardingProductTourBeat] = [
        OnboardingProductTourBeat(.milliseconds(500), .spring(duration: 0.5, bounce: 0.4)),
        OnboardingProductTourBeat(.milliseconds(1700), .smooth(duration: 0.7))
    ] + Array(
        repeating: OnboardingProductTourBeat(.milliseconds(170), .spring(duration: 0.45, bounce: 0.45)),
        count: shownHours
    )

    var body: some View {
        OnboardingProductTourDemo(beats: Self.beats) { phase, canvas in
            OnboardingProductTourWeatherScene(phase: phase, canvas: canvas)
        }
    }
}

private struct OnboardingProductTourWeatherScene: View {
    private static let topHour = 8.0
    private static let events: [OnboardingProductTourEvent] = [
        OnboardingProductTourEvent(start: 8.5, duration: 1, color: .blue),
        OnboardingProductTourEvent(start: 10.25, duration: 1.25, color: .green),
        OnboardingProductTourEvent(start: 12.5, duration: 1, color: .orange)
    ]
    let phase: Int
    let canvas: OnboardingProductTourCanvas

    var body: some View {
        let metrics = canvas.timelineMetrics(firstHour: 6)
        ZStack(alignment: .topLeading) {
            OnboardingProductTourAppScreen {
                OnboardingProductTourTimeline(metrics: metrics, lastHour: 20, topHour: Self.topHour) {
                    ForEach(Array(Self.events.enumerated()), id: \.offset) { _, event in
                        OnboardingProductTourEventBlock(color: event.color)
                            .onboardingProductTourPlaced(in: metrics.frame(for: event))
                    }
                    ForEach(0..<OnboardingProductTourWeatherDemo.shownHours, id: \.self) { index in
                        Image(systemName: OnboardingProductTourWeatherDemo.forecast[index])
                            .symbolRenderingMode(.multicolor)
                            .font(.system(size: 11))
                            .scaleEffect(phase >= 3 + index ? 1 : 0.2)
                            .opacity(phase >= 3 + index ? 1 : 0)
                            .position(
                                x: 6 + metrics.gutterWidth * 0.21,
                                y: metrics.y(for: Self.topHour + Double(index) + 0.45)
                            )
                    }
                }
            }
            OnboardingProductTourLocationBadge(isPulsing: phase == 1)
                .scaleEffect(badgeScale)
                .opacity(phase >= 1 ? 1 : 0)
                .position(badgePosition)
        }
    }

    private var badgeScale: CGFloat {
        switch phase {
        case 0: 0.3
        case 1: 1
        default: 0.38
        }
    }

    private var badgePosition: CGPoint {
        guard phase >= 2 else {
            return CGPoint(x: canvas.size.width / 2, y: canvas.contentTop + canvas.timelineHeight * 0.42)
        }
        return CGPoint(
            x: canvas.size.width - 15.5,
            y: OnboardingProductTourMetrics.statusBarHeight + OnboardingProductTourMetrics.navBarHeight / 2
        )
    }
}

private struct OnboardingProductTourLocationBadge: View {
    let isPulsing: Bool

    var body: some View {
        ZStack {
            if isPulsing {
                OnboardingProductTourPulseRing(delay: 0)
                OnboardingProductTourPulseRing(delay: 0.5)
            }
            Circle()
                .fill(Color.accentColor.gradient)
                .shadow(color: Color.accentColor.opacity(0.4), radius: 6, y: 2)
            Image(systemName: "location.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(width: 34, height: 34)
    }
}

private struct OnboardingProductTourPulseRing: View {
    @State private var isExpanded = false
    let delay: Double

    var body: some View {
        Circle()
            .stroke(Color.accentColor, lineWidth: 2)
            .scaleEffect(isExpanded ? 2.6 : 1)
            .opacity(isExpanded ? 0 : 0.8)
            .onAppear {
                withAnimation(.easeOut(duration: 1.1).repeatForever(autoreverses: false).delay(delay)) {
                    isExpanded = true
                }
            }
    }
}
