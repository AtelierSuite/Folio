import CoreGraphics
import Foundation

extension TimelineLayout {
    /// The card under `location` that can be dragged, and whether the grab is on a resize handle.
    /// Read-only items can't be dragged. Cards drawn later sit on top, so they're checked first.
    public func dragTarget(
        at location: CGPoint,
        geometry: TimelineGridGeometry,
        minimumCardHeight: CGFloat,
        handleHeight: CGFloat
    ) -> TimelineDragTarget? {
        let dayIndex = geometry.dayIndex(atX: location.x)
        let fraction = geometry.fractionWithinDay(atX: location.x)
        let placement = timedPlacements.last { placement in
            guard placement.dayIndex == dayIndex,
                  placement.leadingFraction <= fraction,
                  fraction <= placement.leadingFraction + placement.widthFraction else { return false }
            let top = geometry.y(ofHour: placement.startHour)
            let height = max(minimumCardHeight, geometry.y(ofHour: placement.endHour) - top)
            return top <= location.y && location.y <= top + height
        }
        guard let placement, !placement.entry.isReadOnly else { return nil }
        return TimelineDragTarget(
            placement: placement,
            kind: dragKind(of: placement, at: location.y, geometry: geometry,
                           minimumCardHeight: minimumCardHeight, handleHeight: handleHeight)
        )
    }

    private func dragKind(
        of placement: TimelineTimedPlacement,
        at yPosition: CGFloat,
        geometry: TimelineGridGeometry,
        minimumCardHeight: CGFloat,
        handleHeight: CGFloat
    ) -> TimelineDragKind {
        let top = geometry.y(ofHour: placement.startHour)
        let height = max(minimumCardHeight, geometry.y(ofHour: placement.endHour) - top)
        guard placement.entry.kind == .event, height >= handleHeight * 3 else { return .move }
        if yPosition >= top + height - handleHeight && !placement.continuesToNextDay {
            return .resizeEnd
        }
        if yPosition <= top + handleHeight && !placement.continuesFromPreviousDay {
            return .resizeStart
        }
        return .move
    }
}
