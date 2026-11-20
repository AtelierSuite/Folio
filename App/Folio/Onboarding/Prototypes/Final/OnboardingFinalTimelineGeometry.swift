import SwiftUI

struct OnboardingFinalTimelineGeometry {
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

    func eventFrame(_ event: OnboardingFinalEvent) -> CGRect {
        let minY = yPosition(event.start)
        return CGRect(
            x: contentMinX + 6,
            y: minY,
            width: contentWidth * event.widthFraction,
            height: yPosition(event.end) - minY
        )
    }

    var seedFrame: CGRect {
        CGRect(x: contentMinX + contentWidth / 2 - 18, y: verticalInset, width: 36, height: 22)
    }
}

struct OnboardingFinalEvent: Identifiable {
    let id: Int
    let start: Double
    let end: Double
    let widthFraction: Double
    let color: Color

    static let samples: [OnboardingFinalEvent] = [
        OnboardingFinalEvent(id: 0, start: 1.9, end: 2.95, widthFraction: 0.56, color: .blue),
        OnboardingFinalEvent(id: 1, start: 3.75, end: 5.0, widthFraction: 0.5, color: .purple),
        OnboardingFinalEvent(id: 2, start: 5.6, end: 6.75, widthFraction: 0.56, color: .green)
    ]

    static let alertedIndex = 1
}

enum OnboardingFinalLayerState: Equatable {
    case hidden
    case current
    case completed

    var tintOpacity: Double { self == .current ? 0.6 : 0.3 }
    var contentOpacity: Double { self == .current ? 1 : 0.7 }
}
