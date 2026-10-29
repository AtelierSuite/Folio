import CoreGraphics
import Testing
@testable import Planner

struct TimelineZoomAnchorTests {
    let anchor = TimelineZoomAnchor(verticalInset: 10, viewportHeight: 500)

    @Test func hourUnderTheAnchorStaysInPlace() {
        let contentY = anchor.contentY(ofHour: 12, hourHeight: 48)
        let viewportY: CGFloat = 200
        let offset = anchor.scrollOffset(keepingContentY: contentY, atViewportY: viewportY, from: 48, to: 96)
        #expect(anchor.contentY(ofHour: 12, hourHeight: 96) - offset == viewportY)
    }

    @Test func offsetIsClampedToTheContent() {
        let top = anchor.scrollOffset(keepingContentY: 20, atViewportY: 400, from: 48, to: 60)
        #expect(top == 0)
        let bottom = anchor.scrollOffset(
            keepingContentY: anchor.contentY(ofHour: 24, hourHeight: 48), atViewportY: 0, from: 48, to: 60
        )
        #expect(bottom == anchor.contentHeight(hourHeight: 60) - 500)
    }

    @Test func fittingTheDayScrollsToTheTop() {
        let fitting = TimelineZoom().fittingHourHeight(viewportHeight: 500, verticalInset: 10)
        let offset = anchor.scrollOffset(keepingContentY: 600, atViewportY: 250, from: 48, to: fitting)
        #expect(offset == 0)
    }

    @Test func scaleAnchorIsTheFractionOfTheContent() {
        let height = anchor.contentHeight(hourHeight: 48)
        #expect(anchor.scaleAnchor(contentY: height / 2, hourHeight: 48) == 0.5)
        #expect(anchor.scaleAnchor(contentY: -40, hourHeight: 48) == 0)
        #expect(anchor.scaleAnchor(contentY: height * 2, hourHeight: 48) == 1)
    }
}
