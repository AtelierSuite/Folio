import Foundation

public struct MonthCellOverflow: Sendable, Equatable {
    public let visibleCount: Int
    public let hiddenCount: Int

    /// `capacity` counts rows, and the "+N more" label takes one of them when not everything fits.
    public init(itemCount: Int, capacity: Int) {
        let capacity = max(capacity, 0)
        if itemCount <= capacity {
            visibleCount = itemCount
            hiddenCount = 0
        } else {
            visibleCount = max(capacity - 1, 0)
            hiddenCount = itemCount - visibleCount
        }
    }

    public static func capacity(height: Double, rowHeight: Double, spacing: Double) -> Int {
        guard rowHeight > 0, height >= rowHeight else { return 0 }
        return Int(((height + spacing) / (rowHeight + spacing)).rounded(.down))
    }
}
