import SwiftUI

struct OnboardingProductTourCalendarDemo: View {
    private static let beats: [OnboardingProductTourBeat] = [
        OnboardingProductTourBeat(.milliseconds(600), .easeOut(duration: 0.3)),
        OnboardingProductTourBeat(.milliseconds(250), .smooth(duration: 1.1)),
        OnboardingProductTourBeat(.milliseconds(1100), .easeOut(duration: 0.3)),
        OnboardingProductTourBeat(.milliseconds(150), .spring(duration: 0.55, bounce: 0.3)),
        OnboardingProductTourBeat(.milliseconds(220), .spring(duration: 0.55, bounce: 0.3)),
        OnboardingProductTourBeat(.milliseconds(220), .spring(duration: 0.55, bounce: 0.3))
    ]

    var body: some View {
        OnboardingProductTourDemo(beats: Self.beats) { phase, canvas in
            OnboardingProductTourCalendarScene(phase: phase, canvas: canvas)
        }
    }
}

private struct OnboardingProductTourCalendarScene: View {
    private static let startHour = 7.0
    private static let scrollHours = min(3.5, OnboardingProductTourMetrics.visibleHours * 0.6)
    private static let endHour = startHour + scrollHours
    private static let resident: [OnboardingProductTourEvent] = [
        OnboardingProductTourEvent(start: 7.5, duration: 1.25, color: .blue),
        OnboardingProductTourEvent(start: 9.25, duration: 0.75, color: .teal)
    ]
    private static let arrivals: [OnboardingProductTourEvent] = [
        OnboardingProductTourEvent(start: endHour + 0.5, duration: 1, color: .pink),
        OnboardingProductTourEvent(start: endHour + 1.75, duration: 1.5, lane: 0, laneCount: 2, color: .orange),
        OnboardingProductTourEvent(start: endHour + 2.25, duration: 1.25, lane: 1, laneCount: 2, color: .purple)
    ]
    let phase: Int
    let canvas: OnboardingProductTourCanvas

    var body: some View {
        let metrics = canvas.timelineMetrics(firstHour: 6)
        ZStack(alignment: .topLeading) {
            OnboardingProductTourAppScreen {
                OnboardingProductTourTimeline(
                    metrics: metrics,
                    lastHour: 20,
                    topHour: phase >= 2 ? Self.endHour : Self.startHour
                ) {
                    ForEach(Array(Self.resident.enumerated()), id: \.offset) { _, event in
                        OnboardingProductTourEventBlock(color: event.color)
                            .onboardingProductTourPlaced(in: metrics.frame(for: event))
                    }
                    ForEach(Array(Self.arrivals.enumerated()), id: \.offset) { index, event in
                        let isShown = phase >= 4 + index
                        OnboardingProductTourEventBlock(color: event.color)
                            .opacity(isShown ? 1 : 0)
                            .offset(x: isShown ? 0 : 50)
                            .onboardingProductTourPlaced(in: metrics.frame(for: event))
                    }
                }
            }
            OnboardingProductTourFingertip(
                position: fingerPosition(hourHeight: metrics.hourHeight),
                isVisible: (1...2).contains(phase),
                isPressed: (1...2).contains(phase)
            )
        }
    }

    private func fingerPosition(hourHeight: CGFloat) -> CGPoint {
        let startY = canvas.contentTop + canvas.timelineHeight * 0.85
        let travel = phase >= 2 ? Self.scrollHours * hourHeight : 0
        return CGPoint(x: canvas.size.width * 0.62, y: startY - travel)
    }
}
