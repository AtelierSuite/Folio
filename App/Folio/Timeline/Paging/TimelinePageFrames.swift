import Observation
import SwiftUI

/// Which grid pages are on screen and how far the first one sits from the leading edge, so the
/// day headers and the all-day strip, which sit outside the horizontal scroll view, can follow it.
/// The pages only change when one scrolls in or out; while scrolling, only `leadingOffset` moves.
@MainActor
@Observable
final class TimelinePageFrames {
    struct ShownPages: Equatable {
        let firstPage: Date
        let count: Int
    }

    private(set) var shownPages: ShownPages?
    private(set) var leadingOffset: CGFloat = 0
    var viewportWidth: CGFloat = 0
    @ObservationIgnored private var contentOffset: CGFloat = 0

    func update(contentOffset: CGFloat, pages: TimelinePages) {
        self.contentOffset = contentOffset
        let pageWidth = pages.pageWidth(viewportWidth: viewportWidth)
        guard pageWidth > 0, !pages.starts.isEmpty else { return }
        let firstIndex = min(max(Int(((contentOffset + 0.5) / pageWidth).rounded(.down)), 0), pages.starts.count - 1)
        let offset = CGFloat(firstIndex) * pageWidth - contentOffset
        let count = Int(((viewportWidth - offset) / pageWidth).rounded(.up))
        let shown = ShownPages(
            firstPage: pages.starts[firstIndex],
            count: min(max(count, 1), pages.starts.count - firstIndex)
        )
        if shownPages != shown { shownPages = shown }
        if leadingOffset != offset { leadingOffset = offset }
    }

    func refresh(pages: TimelinePages) {
        update(contentOffset: contentOffset, pages: pages)
    }
}
