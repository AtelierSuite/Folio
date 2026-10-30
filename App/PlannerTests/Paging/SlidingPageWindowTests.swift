import Testing
@testable import Planner

struct SlidingPageWindowTests {
    @Test func offsetsRunEitherSideOfTheCentre() {
        let window = SlidingPageWindow(radius: 3)
        #expect(window.offsets == -3...3)
        #expect(window.pageCount == 7)
    }

    @Test func recentersOnlyPastTheDistance() {
        let window = SlidingPageWindow(radius: 9, recenteringDistance: 3)
        #expect(!window.needsRecentering(atIndex: 9))
        #expect(!window.needsRecentering(atIndex: 6))
        #expect(!window.needsRecentering(atIndex: 12))
        #expect(window.needsRecentering(atIndex: 5))
        #expect(window.needsRecentering(atIndex: 13))
    }

    @Test func defaultDistanceIsAThirdOfTheRadius() {
        #expect(SlidingPageWindow(radius: 21).recenteringDistance == 7)
    }

    @Test func distanceIsClampedToTheRadius() {
        #expect(SlidingPageWindow(radius: 2, recenteringDistance: 10).recenteringDistance == 2)
        #expect(SlidingPageWindow(radius: -4).radius == 0)
    }
}
