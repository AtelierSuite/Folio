import CoreGraphics

/// Where a horizontal timeline fling comes to rest. Day views can carry across several days
/// and settle on a day boundary; week views move at most one week from where the drag began.
public struct TimelineScrollSnapping: Sendable, Hashable {
    public var columnsOnScreen: Int
    public var columnsPerStep: Int
    public var limitsToOneStep: Bool

    public init(columnsOnScreen: Int, columnsPerStep: Int = 1, limitsToOneStep: Bool = false) {
        self.columnsOnScreen = max(columnsOnScreen, 1)
        self.columnsPerStep = max(columnsPerStep, 1)
        self.limitsToOneStep = limitsToOneStep
    }

    public func stepWidth(containerWidth: CGFloat) -> CGFloat {
        containerWidth / CGFloat(columnsOnScreen) * CGFloat(columnsPerStep)
    }

    public func targetOffset(
        proposed: CGFloat,
        start: CGFloat,
        containerWidth: CGFloat,
        contentWidth: CGFloat
    ) -> CGFloat {
        let stepWidth = stepWidth(containerWidth: containerWidth)
        guard stepWidth > 0 else { return proposed }
        var step = (proposed / stepWidth).rounded()
        if limitsToOneStep {
            let startStep = (start / stepWidth).rounded()
            step = min(max(step, startStep - 1), startStep + 1)
        }
        let maximumOffset = max(contentWidth - containerWidth, 0)
        return min(max(step * stepWidth, 0), maximumOffset)
    }
}
