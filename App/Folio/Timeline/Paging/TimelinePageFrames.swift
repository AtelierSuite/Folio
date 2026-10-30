import Observation
import SwiftUI

/// Where each rendered grid page sits across the horizontal scroll view, so the day headers and
/// the all-day strip, which sit outside it, can follow the grid as it scrolls.
@MainActor
@Observable
final class TimelinePageFrames {
    struct Frame: Equatable {
        let page: Date
        let minX: CGFloat
        let width: CGFloat
    }

    private(set) var frames: [Date: Frame] = [:]
    var viewportWidth: CGFloat = 0

    func update(_ page: Date, minX: CGFloat, width: CGFloat) {
        let frame = Frame(page: page, minX: minX, width: width)
        if frames[page] != frame { frames[page] = frame }
    }

    /// When the pages are rebuilt at a new width, the new page can report in before the old one
    /// disappears, so only a frame of the old width is dropped.
    func remove(_ page: Date, width: CGFloat) {
        if frames[page]?.width == width { frames[page] = nil }
    }

    var visible: [Frame] {
        frames.values
            .filter { $0.minX < viewportWidth && $0.minX + $0.width > 0 }
            .sorted { $0.minX < $1.minX }
    }
}
