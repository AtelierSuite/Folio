import Planner
import SwiftUI

/// The grid's horizontal scroll view. Pages are built lazily, the offset is reported to `frames`,
/// and the whole strip is one drag surface so a card can be moved from one page to the next.
struct TimelinePageScrollView<Page: View>: View {
    @Environment(TimelineDragController.self) private var drag: TimelineDragController?
    let pages: TimelinePages
    @Binding var position: ScrollPosition
    let frames: TimelinePageFrames
    let isScrollDisabled: Bool
    var onScrollPhaseChange: ((ScrollPhase) -> Void)?
    @ViewBuilder let page: (Date) -> Page
    @State private var anchoredPage: Date?
    @State private var viewportWidth: CGFloat = 0

    private var pageWidth: CGFloat {
        pages.pageWidth(viewportWidth: viewportWidth)
    }

    var body: some View {
        ScrollView(.horizontal) {
            if viewportWidth > 0 {
                pageStack
            }
        }
        .scrollTargetBehavior(TimelineScrollTargetBehavior(snapping: pages.snapping))
        .scrollPosition($position, anchor: .leading)
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        .scrollDisabled(isScrollDisabled || drag?.isActive == true)
        .onScrollPhaseChange { _, phase in
            if phase == .idle { anchoredPage = position.viewID(type: Date.self) }
            onScrollPhaseChange?(phase)
        }
        .onChange(of: position.viewID(type: Date.self), initial: true) { _, page in
            if !position.isPositionedByUser { anchoredPage = page }
        }
        .onScrollGeometryChange(for: CGFloat.self) { $0.contentOffset.x } action: { _, offset in
            frames.update(contentOffset: offset, pages: pages)
        }
        .modifier(TimelineDayEdgeHapticsModifier(columnsOnScreen: pages.columnsOnScreen))
        .onChange(of: pages) { frames.refresh(pages: pages) }
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width in
            viewportWidth = width
            frames.viewportWidth = width
            frames.refresh(pages: pages)
            keepAnchoredPage()
        }
        .onGeometryChange(for: CGRect.self) { $0.frame(in: TimelineDragController.coordinateSpace) } action: {
            drag?.pagingFrame = $0
        }
    }

    /// Pages get an explicit width, and the stack is rebuilt when it changes: a lazy stack keeps
    /// estimating the pages it hasn't built at the size it last measured, which would leave pages
    /// off the snapping grid.
    private var pageStack: some View {
        LazyHStack(spacing: 0) {
            ForEach(pages.starts, id: \.self) { start in
                page(start)
                    .frame(width: pageWidth)
            }
        }
        .scrollTargetLayout()
        .onGeometryChange(for: CGRect.self) { $0.frame(in: TimelineDragController.coordinateSpace) } action: {
            drag?.updateGridFrame($0)
        }
        .timelineGridDragging(drag)
        .id(pageWidth)
    }

    /// The scroll view keeps its offset in points when it's resized, which would leave it part way
    /// between pages now that every page has a new width.
    private func keepAnchoredPage() {
        guard let anchoredPage else { return }
        position.scrollTo(id: anchoredPage, anchor: .leading)
    }
}
