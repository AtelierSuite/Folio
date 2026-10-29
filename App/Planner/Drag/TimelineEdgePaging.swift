import CoreGraphics
import Foundation

/// A drag held against the leading or trailing edge of the timeline turns the page,
/// so an item can be moved to days that aren't shown.
public struct TimelineEdgePaging: Sendable, Equatable {
    public var edgeWidth: CGFloat
    public var holdDuration: Duration

    public init(edgeWidth: CGFloat = 24, holdDuration: Duration = .milliseconds(600)) {
        self.edgeWidth = edgeWidth
        self.holdDuration = holdDuration
    }

    public func direction(pointerX: CGFloat, width: CGFloat) -> CalendarPageDirection? {
        guard width > edgeWidth * 4 else { return nil }
        if pointerX < edgeWidth { return .backward }
        if pointerX > width - edgeWidth { return .forward }
        return nil
    }
}
