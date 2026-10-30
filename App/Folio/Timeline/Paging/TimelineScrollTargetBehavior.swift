import Planner
import SwiftUI

struct TimelineScrollTargetBehavior: ScrollTargetBehavior {
    let snapping: TimelineScrollSnapping

    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        target.rect.origin.x = snapping.targetOffset(
            proposed: target.rect.minX,
            start: context.originalTarget.rect.minX,
            containerWidth: context.containerSize.width,
            contentWidth: context.contentSize.width
        )
    }
}
