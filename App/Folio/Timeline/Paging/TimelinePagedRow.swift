import SwiftUI

/// A row above the grid that shows the pages the grid shows, in the same place. It isn't a
/// scroll view itself: it follows the scroll offset the grid reports.
struct TimelinePagedRow<Content: View>: View {
    let frames: TimelinePageFrames
    let pages: TimelinePages
    let scrolledPage: Date?
    @ViewBuilder let content: (Date) -> Content

    var body: some View {
        let pageWidth = pages.pageWidth(viewportWidth: frames.viewportWidth)
        let shown = shownPages(pageWidth: pageWidth)
        HStack(alignment: .top, spacing: 0) {
            ForEach(shown.pages, id: \.self) { page in
                content(page)
                    .frame(width: pageWidth)
            }
        }
        .fixedSize(horizontal: true, vertical: false)
        .modifier(TimelinePagedRowOffset(frames: frames, followsScroll: shown.followsScroll))
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .clipped()
    }

    /// Until the grid reports where it is, or while it reports pages from before a rebuild, the
    /// pages are drawn from the scrolled page onwards, which is where a freshly built grid sits.
    private func shownPages(pageWidth: CGFloat) -> (pages: ArraySlice<Date>, followsScroll: Bool) {
        if let shown = frames.shownPages, let first = pages.index(of: shown.firstPage) {
            return (pages.starts[first..<min(first + shown.count, pages.starts.count)], true)
        }
        guard pageWidth > 0, let scrolledPage, let first = pages.index(of: scrolledPage) else { return ([], false) }
        let count = Int((frames.viewportWidth / pageWidth).rounded(.up))
        return (pages.starts[first..<min(first + count, pages.starts.count)], false)
    }
}

/// Reads the offset on its own, so scrolling moves the row without building its pages again.
private struct TimelinePagedRowOffset: ViewModifier {
    let frames: TimelinePageFrames
    let followsScroll: Bool

    func body(content: Content) -> some View {
        content.offset(x: followsScroll ? frames.leadingOffset : 0)
    }
}
