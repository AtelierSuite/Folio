import CoreGraphics
import Testing
@testable import Planner

struct TimelineAutoScrollTests {
    private let autoScroll = TimelineAutoScroll(edgeHeight: 50, maximumSpeed: 1000)

    @Test func staysStillAwayFromTheEdges() {
        #expect(autoScroll.speed(pointerY: 300, viewportHeight: 600) == 0)
        #expect(autoScroll.speed(pointerY: 50, viewportHeight: 600) == 0)
    }

    @Test func rampsUpTowardsTheEdges() {
        #expect(autoScroll.speed(pointerY: 25, viewportHeight: 600) == -500)
        #expect(autoScroll.speed(pointerY: 0, viewportHeight: 600) == -1000)
        #expect(autoScroll.speed(pointerY: 575, viewportHeight: 600) == 500)
        #expect(autoScroll.speed(pointerY: 700, viewportHeight: 600) == 1000)
        #expect(autoScroll.speed(pointerY: -80, viewportHeight: 600) == -1000)
    }

    private func offset(from offset: CGFloat, speed: CGFloat, for duration: Double) -> CGFloat {
        autoScroll.offset(
            afterScrolling: offset, speed: speed, for: duration, contentHeight: 1200, viewportHeight: 600
        )
    }

    @Test func offsetIsClampedToTheContent() {
        #expect(offset(from: 10, speed: -1000, for: 0.1) == 0)
        #expect(offset(from: 590, speed: 1000, for: 0.1) == 600)
        #expect(offset(from: 100, speed: 600, for: 0.5) == 400)
    }

    @Test func tinyViewportsDontScroll() {
        #expect(autoScroll.speed(pointerY: 0, viewportHeight: 80) == 0)
    }
}
