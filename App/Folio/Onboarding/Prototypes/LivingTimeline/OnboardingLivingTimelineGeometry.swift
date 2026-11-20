import SwiftUI

struct OnboardingLivingTimelineGeometry {
    static let rowCount = 8

    let size: CGSize
    let gutterWidth: CGFloat
    let verticalInset: CGFloat

    var rowHeight: CGFloat { (size.height - verticalInset * 2) / CGFloat(Self.rowCount) }
    var contentMinX: CGFloat { gutterWidth }
    var contentMaxX: CGFloat { size.width - 12 }
    var contentWidth: CGFloat { contentMaxX - contentMinX }

    func yPosition(_ hour: Double) -> CGFloat {
        verticalInset + CGFloat(hour) * rowHeight + rowHeight / 2
    }

    func eventFrame(_ event: OnboardingLivingTimelineEvent) -> CGRect {
        let minY = yPosition(event.start)
        return CGRect(
            x: contentMinX + 6,
            y: minY,
            width: contentWidth * event.widthFraction,
            height: yPosition(event.end) - minY
        )
    }

    var remindersMinX: CGFloat { contentMinX + contentWidth * 0.62 }
}

struct OnboardingLivingTimelineEvent: Identifiable {
    let id: Int
    let start: Double
    let end: Double
    let widthFraction: Double
    let color: Color

    static let samples: [OnboardingLivingTimelineEvent] = [
        OnboardingLivingTimelineEvent(id: 0, start: 1.9, end: 2.95, widthFraction: 0.56, color: .blue),
        OnboardingLivingTimelineEvent(id: 1, start: 3.75, end: 5.0, widthFraction: 0.5, color: .pink),
        OnboardingLivingTimelineEvent(id: 2, start: 5.6, end: 6.75, widthFraction: 0.56, color: .green)
    ]

    static let alertedIndex = 1
}

enum OnboardingLivingTimelineLayerState: Equatable {
    case hidden
    case current
    case completed
}
