import Foundation

public struct TimelineDragTarget: Sendable, Hashable {
    public let placement: TimelineTimedPlacement
    public let kind: TimelineDragKind

    public init(placement: TimelineTimedPlacement, kind: TimelineDragKind) {
        self.placement = placement
        self.kind = kind
    }
}
