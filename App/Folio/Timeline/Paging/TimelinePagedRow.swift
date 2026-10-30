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

    /// Before the grid has reported anything, the scrolled page is drawn where it will be.
    private var shownFrames: [TimelinePageFrames.Frame] {
        let visible = frames.visible
        guard visible.isEmpty, let scrolledPage else { return visible }
        let pageWidth = frames.viewportWidth / CGFloat(pages.columnsOnScreen) * CGFloat(pages.daysPerPage)
        return [TimelinePageFrames.Frame(page: scrolledPage, minX: 0, width: pageWidth)]
    }
}
