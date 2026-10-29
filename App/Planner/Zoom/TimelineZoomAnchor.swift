import CoreGraphics

/// Keeps the hour under the pinch (or the middle of the viewport) in place when the hour height changes.
public struct TimelineZoomAnchor: Sendable, Equatable {
    public var verticalInset: CGFloat
    public var viewportHeight: CGFloat

    public init(verticalInset: CGFloat, viewportHeight: CGFloat) {
        self.verticalInset = verticalInset
        self.viewportHeight = viewportHeight
    }

    public func contentHeight(hourHeight: CGFloat) -> CGFloat {
        hourHeight * 24 + verticalInset * 2
    }

    public func hour(atContentY contentY: CGFloat, hourHeight: CGFloat) -> CGFloat {
        guard hourHeight > 0 else { return 0 }
        return min(max((contentY - verticalInset) / hourHeight, 0), 24)
    }

    public func contentY(ofHour hour: CGFloat, hourHeight: CGFloat) -> CGFloat {
        hour * hourHeight + verticalInset
    }

    public func scrollOffset(
        keepingContentY contentY: CGFloat,
        atViewportY viewportY: CGFloat,
        from oldHourHeight: CGFloat,
        to newHourHeight: CGFloat
    ) -> CGFloat {
        let anchoredHour = hour(atContentY: contentY, hourHeight: oldHourHeight)
        let target = self.contentY(ofHour: anchoredHour, hourHeight: newHourHeight) - viewportY
        let maximumOffset = max(0, contentHeight(hourHeight: newHourHeight) - viewportHeight)
        return min(max(target, 0), maximumOffset)
    }

    /// The unit point to scale the content around so `contentY` stays put during a pinch.
    public func scaleAnchor(contentY: CGFloat, hourHeight: CGFloat) -> CGFloat {
        let height = contentHeight(hourHeight: hourHeight)
        guard height > 0 else { return 0.5 }
        return min(max(contentY / height, 0), 1)
    }
}
