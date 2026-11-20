import SwiftUI

struct OnboardingProductTourSleepDemo: View {
    private static let beats: [OnboardingProductTourBeat] = [
        OnboardingProductTourBeat(.milliseconds(600), .easeOut(duration: 0.25)),
        OnboardingProductTourBeat(.milliseconds(250), .smooth(duration: 1.4)),
        OnboardingProductTourBeat(.milliseconds(350), .easeOut(duration: 0.25)),
        OnboardingProductTourBeat(.milliseconds(1000), .smooth(duration: 1.1)),
        OnboardingProductTourBeat(.milliseconds(1100), .spring(duration: 0.5, bounce: 0.45))
    ]

    var body: some View {
        OnboardingProductTourDemo(beats: Self.beats, hold: .seconds(2.8)) { phase, canvas in
            OnboardingProductTourSleepScene(phase: phase, canvas: canvas)
        }
    }
}

private struct OnboardingProductTourSleepScene: View {
    private static let startHour = 8.0
    private static let endHour = max(0.25, 7.6 - OnboardingProductTourMetrics.visibleHours)
    private static let bedtime = 0.75
    private static let wakeTime = 6.5
    private static let events: [OnboardingProductTourEvent] = [
        OnboardingProductTourEvent(start: 6.75, duration: 0.75, color: .orange),
        OnboardingProductTourEvent(start: 8.5, duration: 1, color: .blue),
        OnboardingProductTourEvent(start: 10, duration: 1.5, color: .green),
        OnboardingProductTourEvent(start: 12.25, duration: 1, color: .pink)
    ]
    let phase: Int
    let canvas: OnboardingProductTourCanvas

    var body: some View {
        let metrics = canvas.timelineMetrics(firstHour: 0)
        ZStack(alignment: .topLeading) {
            OnboardingProductTourAppScreen {
                OnboardingProductTourTimeline(
                    metrics: metrics,
                    lastHour: 16,
                    topHour: phase >= 2 ? Self.endHour : Self.startHour
                ) {
                    ForEach(Array(Self.events.enumerated()), id: \.offset) { _, event in
                        OnboardingProductTourEventBlock(color: event.color)
                            .onboardingProductTourPlaced(in: metrics.frame(for: event))
                    }
                    OnboardingProductTourSleepBlock(showsMoon: phase >= 5)
                        .onboardingProductTourPlaced(in: sleepRect(metrics: metrics))
                    Image(systemName: "sun.horizon.fill")
                        .symbolRenderingMode(.multicolor)
                        .font(.system(size: 11))
                        .scaleEffect(phase >= 5 ? 1 : 0.2)
                        .opacity(phase >= 5 ? 1 : 0)
                        .position(x: 6 + metrics.gutterWidth * 0.21, y: metrics.y(for: Self.wakeTime))
                }
            }
            OnboardingProductTourFingertip(
                position: fingerPosition,
                isVisible: (1...2).contains(phase),
                isPressed: (1...2).contains(phase)
            )
            .animation(.easeIn(duration: 0.35), value: phase)
        }
    }

    private var fingerPosition: CGPoint {
        let startY = canvas.contentTop + canvas.timelineHeight * 0.2
        return CGPoint(x: canvas.size.width * 0.62, y: startY + (phase >= 2 ? canvas.timelineHeight * 0.5 : 0))
    }

    private func sleepRect(metrics: OnboardingProductTourTimelineMetrics) -> CGRect {
        let fullRect = metrics.frame(for: OnboardingProductTourEvent(
            start: Self.bedtime,
            duration: Self.wakeTime - Self.bedtime,
            color: .indigo
        ))
        var rect = fullRect
        rect.size.height = phase >= 4 ? fullRect.height : 0
        return rect
    }
}

private struct OnboardingProductTourSleepBlock: View {
    let showsMoon: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(LinearGradient(
                colors: [.indigo, .purple.opacity(0.85), .teal.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            ))
            .overlay(alignment: .bottomLeading) {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
                    .scaleEffect(showsMoon ? 1 : 0.2)
                    .opacity(showsMoon ? 1 : 0)
                    .padding(6)
            }
            .clipped()
    }
}
