import SwiftUI

struct OnboardingProductTourBootDemo: View {
    private static let beats: [OnboardingProductTourBeat] = [
        OnboardingProductTourBeat(.milliseconds(400), .spring(duration: 0.6, bounce: 0.3)),
        OnboardingProductTourBeat(.milliseconds(1000), .easeInOut(duration: 0.8)),
        OnboardingProductTourBeat(.milliseconds(250), .spring(duration: 0.5, bounce: 0.3)),
        OnboardingProductTourBeat(.milliseconds(180), .spring(duration: 0.5, bounce: 0.3)),
        OnboardingProductTourBeat(.milliseconds(180), .spring(duration: 0.5, bounce: 0.3)),
        OnboardingProductTourBeat(.milliseconds(250), .easeOut(duration: 0.5))
    ]

    var body: some View {
        OnboardingProductTourDemo(beats: Self.beats, loops: false) { phase, canvas in
            OnboardingProductTourBootScene(phase: phase, canvas: canvas)
        }
    }
}

private struct OnboardingProductTourBootScene: View {
    private static let events: [OnboardingProductTourEvent] = [
        OnboardingProductTourEvent(start: 8.5, duration: 1, color: .blue),
        OnboardingProductTourEvent(start: 10, duration: 1.5, lane: 0, laneCount: 2, color: .pink),
        OnboardingProductTourEvent(start: 10.5, duration: 1, lane: 1, laneCount: 2, color: .orange),
        OnboardingProductTourEvent(start: 12.25, duration: 0.75, color: .green)
    ]
    let phase: Int
    let canvas: OnboardingProductTourCanvas

    var body: some View {
        let metrics = canvas.timelineMetrics(firstHour: 7)
        ZStack {
            OnboardingProductTourAppScreen {
                OnboardingProductTourTimeline(metrics: metrics, lastHour: 20, topHour: 8) {
                    ForEach(Array(Self.events.enumerated()), id: \.offset) { index, event in
                        OnboardingProductTourEventBlock(color: event.color)
                            .scaleEffect(phase >= 3 + min(index, 2) ? 1 : 0.6, anchor: .top)
                            .opacity(phase >= 3 + min(index, 2) ? 1 : 0)
                            .onboardingProductTourPlaced(in: metrics.frame(for: event))
                    }
                    OnboardingProductTourNowLine(metrics: metrics, hour: 9.7)
                        .opacity(phase >= 6 ? 1 : 0)
                }
            }
            Color.black
                .opacity(phase >= 2 ? 0 : 1)
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(colors: [.pink, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay {
                    Image(systemName: "calendar.day.timeline.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: 44, height: 44)
                .scaleEffect(phase == 0 ? 0.6 : (phase == 1 ? 1 : 1.4))
                .opacity(phase == 1 ? 1 : 0)
        }
    }
}
