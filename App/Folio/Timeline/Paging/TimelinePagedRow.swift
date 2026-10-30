import SwiftUI

/// A row above the grid that shows the pages the grid shows, in the same place. It isn't a
/// scroll view itself: it follows the frames the grid pages report.
struct TimelinePagedRow<Content: View>: View {
    let frames: TimelinePageFrames
    let pages: TimelinePages
    let scrolledPage: Date?
    @ViewBuilder let content: (Date) -> Content

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(shownFrames, id: \.page) { frame in
                content(frame.page)
                    .frame(width: frame.width)
                    .offset(x: frame.minX)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .clipped()
    }

    /// Until the grid's pages report in, which they only do once they move, the pages are drawn
    /// from the scrolled page onwards, which is where a freshly built grid sits.
    private var shownFrames: [TimelinePageFrames.Frame] {
        let pageWidth = frames.viewportWidth / CGFloat(max(pages.columnsOnScreen, 1)) * CGFloat(pages.daysPerPage)
        let visible = frames.visible(pageWidth: pageWidth)
        guard visible.isEmpty, pageWidth > 0, let scrolledPage, let first = pages.index(of: scrolledPage) else {
            return visible
        }
        let count = Int((frames.viewportWidth / pageWidth).rounded(.up))
        return (first..<min(first + count, pages.starts.count)).map { index in
            TimelinePageFrames.Frame(
                page: pages.starts[index], minX: CGFloat(index - first) * pageWidth, width: pageWidth
            )
        }
    }
}
