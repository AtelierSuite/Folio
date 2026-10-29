import Foundation

public enum TimelineDragKind: Sendable, Hashable {
    case move
    case resizeStart
    case resizeEnd
    /// An all-day reminder dropped onto the time grid, which gives it a due time.
    case place(duration: TimeInterval)
}
