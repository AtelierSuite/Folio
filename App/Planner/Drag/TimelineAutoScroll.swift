import CoreGraphics
import Foundation

/// How fast the timeline scrolls while a drag is held near its top or bottom edge.
/// Negative speeds scroll up. Speed ramps up linearly towards the edge.
public struct TimelineAutoScroll: Sendable, Equatable {
    public var edgeHeight: CGFloat
    public var maximumSpeed: CGFloat

    public init(edgeHeight: CGFloat = 56, maximumSpeed: CGFloat = 900) {
        self.edgeHeight = edgeHeight
        self.maximumSpeed = maximumSpeed
    }

    public func speed(pointerY: CGFloat, viewportHeight: CGFloat) -> CGFloat {
        guard viewportHeight > edgeHeight * 2, edgeHeight > 0 else { return 0 }
        if pointerY < edgeHeight {
            return -maximumSpeed * min(1, (edgeHeight - pointerY) / edgeHeight)
        }
        if pointerY > viewportHeight - edgeHeight {
            return maximumSpeed * min(1, (pointerY - (viewportHeight - edgeHeight)) / edgeHeight)
        }
        return 0
    }

    public func offset(
        afterScrolling offset: CGFloat,
        speed: CGFloat,
        for duration: TimeInterval,
        contentHeight: CGFloat,
        viewportHeight: CGFloat
    ) -> CGFloat {
        let maximumOffset = max(contentHeight - viewportHeight, 0)
        return min(max(offset + speed * CGFloat(duration), 0), maximumOffset)
    }
}
