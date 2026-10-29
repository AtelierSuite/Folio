import Planner
import SwiftUI

/// Scrolls the timeline while a drag is held near its top or bottom edge.
struct TimelineDragAutoScrollModifier: ViewModifier {
    @Environment(TimelineDragController.self) private var drag: TimelineDragController?
    @Binding var position: ScrollPosition
    let pinch: TimelinePinchState
    let contentHeight: CGFloat

    private let autoScroll = TimelineAutoScroll()
    private let frameDuration = 1.0 / 60

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGRect.self) { $0.frame(in: TimelineDragController.coordinateSpace) } action: {
                drag?.viewportFrame = $0
            }
            .task(id: (drag?.autoScrollSpeed ?? 0) != 0) {
                while let speed = drag?.autoScrollSpeed, speed != 0, !Task.isCancelled {
                    let offset = autoScroll.offset(
                        afterScrolling: pinch.scrollOffset, speed: speed, for: frameDuration,
                        contentHeight: contentHeight, viewportHeight: pinch.viewportHeight
                    )
                    if offset != pinch.scrollOffset {
                        position.scrollTo(y: offset)
                        pinch.scrollOffset = offset
                    }
                    try? await Task.sleep(for: .seconds(frameDuration))
                }
            }
    }
}
