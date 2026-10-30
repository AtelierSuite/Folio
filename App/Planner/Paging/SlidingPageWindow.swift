import Foundation

/// A run of pages on either side of a centre page. Once the page in view drifts more than
/// `recenteringDistance` from the centre, the window is rebuilt around it, so scrolling never
/// reaches an end.
public struct SlidingPageWindow: Sendable, Hashable {
    public let radius: Int
    public let recenteringDistance: Int

    public init(radius: Int, recenteringDistance: Int? = nil) {
        let radius = max(radius, 0)
        self.radius = radius
        self.recenteringDistance = min(max(recenteringDistance ?? radius / 3, 0), radius)
    }

    public var offsets: ClosedRange<Int> {
        -radius...radius
    }

    public var pageCount: Int {
        radius * 2 + 1
    }

    public func needsRecentering(atIndex index: Int) -> Bool {
        abs(index - radius) > recenteringDistance
    }
}
