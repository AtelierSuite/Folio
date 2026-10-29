import CoreGraphics
import Testing
@testable import Planner

struct TimelineEdgePagingTests {
    private let paging = TimelineEdgePaging(edgeWidth: 20)

    @Test func edgesPage() {
        #expect(paging.direction(pointerX: 5, width: 400) == .backward)
        #expect(paging.direction(pointerX: -10, width: 400) == .backward)
        #expect(paging.direction(pointerX: 395, width: 400) == .forward)
        #expect(paging.direction(pointerX: 200, width: 400) == nil)
    }

    @Test func narrowGridsDontPage() {
        #expect(paging.direction(pointerX: 5, width: 60) == nil)
    }
}
