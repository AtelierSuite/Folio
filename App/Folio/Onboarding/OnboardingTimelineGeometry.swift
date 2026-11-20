import SwiftUI

struct OnboardingTimelineGeometry {
    static let rowCount = 8

    let size: CGSize
    let gutterWidth: CGFloat
    let verticalInset: CGFloat

    var rowHeight: CGFloat { (size.height - verticalInset * 2) / CGFloat(Self.rowCount) }
    var contentMinX: CGFloat { gutterWidth }
    var contentMaxX: CGFloat { size.width - 12 }
    var contentWidth: CGFloat { contentMaxX - contentMinX }
    var remindersMinX: CGFloat { contentMinX + contentWidth * 0.66 }

    func yPosition(_ hour: Double) -> CGFloat {
        verticalInset + CGFloat(hour) * rowHeight + rowHeight / 2
    }

    func eventFrame(_ event: OnboardingEvent, isSharingRow: Bool) -> CGRect {
        let minY = yPosition(event.start)
        let fraction = isSharingRow ? OnboardingEvent.sharedWidthFraction : OnboardingEvent.fullWidthFraction
        return CGRect(
            x: contentMinX + 6,
            y: minY,
            width: (contentWidth - 6) * fraction,
            height: yPosition(event.end) - minY
        )
    }

    static let seedDiameter: CGFloat = 30

    static func seedFrame(at center: CGPoint) -> CGRect {
        CGRect(
            x: center.x - seedDiameter / 2,
            y: center.y - seedDiameter / 2,
            width: seedDiameter,
            height: seedDiameter
        )
    }
}

struct OnboardingEvent: Identifiable {
    let id: Int
    let start: Double
    let end: Double
    let color: Color

    static let samples: [OnboardingEvent] = [
        OnboardingEvent(id: 0, start: 1.9, end: 2.95, color: .blue),
        OnboardingEvent(id: 1, start: 3.75, end: 5.0, color: .purple),
        OnboardingEvent(id: 2, start: 5.6, end: 6.75, color: .green)
    ]

    static let alertedIndex = 1
    static let sharedWidthFraction = 0.6
    static let fullWidthFraction = 1.0
}

enum OnboardingLayerState: Equatable {
    case hidden
    case current
    case completed
    case declined

    var isShown: Bool { self == .current || self == .completed }

    var tintOpacity: Double { self == .current ? 0.6 : 0.3 }
    var contentOpacity: Double { self == .current ? 1 : 0.7 }
}
