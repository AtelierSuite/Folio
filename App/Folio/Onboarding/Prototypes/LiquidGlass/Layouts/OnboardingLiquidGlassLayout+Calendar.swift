import SwiftUI

extension OnboardingLiquidGlassLayout {
    private struct Event {
        let start: Double
        let duration: Double
        var lane = 0
        var laneCount = 1
        let color: Color
    }

    private static let events: [Event] = [
        Event(start: 0.15, duration: 0.85, color: .red),
        Event(start: 1.2, duration: 1.1, lane: 0, laneCount: 2, color: .blue),
        Event(start: 1.55, duration: 1.05, lane: 1, laneCount: 2, color: .teal),
        Event(start: 2.95, duration: 0.85, color: .orange)
    ]

    var calendarPieces: [OnboardingLiquidGlassPiece] {
        Self.events.enumerated().map { index, event in
            if index < phase {
                OnboardingLiquidGlassPiece(
                    id: index,
                    frame: timeline.frame(
                        start: event.start,
                        duration: event.duration,
                        lane: event.lane,
                        laneCount: event.laneCount
                    ),
                    cornerRadius: 12,
                    tint: event.color,
                    content: .event(event.color)
                )
            } else {
                OnboardingLiquidGlassPiece(
                    id: index,
                    frame: CGRect(
                        center: CGPoint(
                            x: size.width - 34 - CGFloat(index) * 5,
                            y: size.height / 2 + CGFloat(index) * 7 - 10
                        ),
                        size: CGSize(width: 44, height: 44)
                    ),
                    tint: event.color,
                    content: .dot(event.color)
                )
            }
        }
    }
}
