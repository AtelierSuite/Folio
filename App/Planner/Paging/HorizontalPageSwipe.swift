import CoreGraphics

/// Decides whether a drag is a horizontal page swipe. The axis is locked once the drag has
/// moved far enough, so vertical scrolling, pinching and dragging items keep their gestures.
public struct HorizontalPageSwipe: Sendable, Equatable {
    public var axisLockDistance: CGFloat = 12
    public var horizontalDominance: CGFloat = 1.5
    public var commitFraction: CGFloat = 0.3
    public var flickFraction: CGFloat = 0.6

    public init() {}

    public enum Axis: Sendable, Equatable {
        case horizontal
        case vertical
    }

    public func lockedAxis(for translation: CGSize) -> Axis? {
        let horizontal = abs(translation.width)
        let vertical = abs(translation.height)
        guard max(horizontal, vertical) >= axisLockDistance else { return nil }
        return horizontal >= vertical * horizontalDominance ? .horizontal : .vertical
    }

    public func direction(
        translation: CGFloat,
        predictedEndTranslation: CGFloat,
        pageWidth: CGFloat
    ) -> CalendarPageDirection? {
        guard pageWidth > 0, translation != 0 else { return nil }
        let isMovingBack = predictedEndTranslation.sign != translation.sign
            && abs(predictedEndTranslation) > axisLockDistance
        guard !isMovingBack else { return nil }
        let reachesCommit = abs(translation) >= pageWidth * commitFraction
            || abs(predictedEndTranslation) >= pageWidth * flickFraction
        guard reachesCommit else { return nil }
        return translation < 0 ? .forward : .backward
    }
}
