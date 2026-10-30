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

    /// Keyed by width too: when the pages are rebuilt at a new width, the old pages keep reporting
    /// until they're gone, and readers only want the pages of the current width.
    private struct Key: Hashable {
        let page: Date
        let width: CGFloat
    }

    private var frames: [Key: Frame] = [:]
    var viewportWidth: CGFloat = 0

    func update(_ page: Date, minX: CGFloat, width: CGFloat) {
        let key = Key(page: page, width: width)
        let frame = Frame(page: page, minX: minX, width: width)
        if frames[key] != frame { frames[key] = frame }
    }

    func remove(_ page: Date, width: CGFloat) {
        frames[Key(page: page, width: width)] = nil
    }

    func visible(pageWidth: CGFloat) -> [Frame] {
        frames.values
            .filter { abs($0.width - pageWidth) < 0.5 }
            .filter { $0.minX < viewportWidth && $0.minX + $0.width > 0 }
            .sorted { $0.minX < $1.minX }
    }
}
