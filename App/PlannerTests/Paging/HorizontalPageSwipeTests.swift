import CoreGraphics
import Testing
@testable import Planner

struct HorizontalPageSwipeTests {
    let swipe = HorizontalPageSwipe()

    @Test func axisStaysOpenForSmallMovements() {
        #expect(swipe.lockedAxis(for: CGSize(width: 4, height: 3)) == nil)
    }

    @Test func mostlyHorizontalDragLocksHorizontal() {
        #expect(swipe.lockedAxis(for: CGSize(width: -30, height: 8)) == .horizontal)
    }

    @Test func diagonalOrVerticalDragLocksVertical() {
        #expect(swipe.lockedAxis(for: CGSize(width: 20, height: 18)) == .vertical)
        #expect(swipe.lockedAxis(for: CGSize(width: 2, height: 40)) == .vertical)
    }

    @Test func swipingLeftPastTheThresholdPagesForward() {
        #expect(swipe.direction(translation: -140, predictedEndTranslation: -150, pageWidth: 400) == .forward)
    }

    @Test func swipingRightPastTheThresholdPagesBackward() {
        #expect(swipe.direction(translation: 140, predictedEndTranslation: 150, pageWidth: 400) == .backward)
    }

    @Test func shortSlowDragDoesNotPage() {
        #expect(swipe.direction(translation: -60, predictedEndTranslation: -70, pageWidth: 400) == nil)
    }

    @Test func shortFlickPages() {
        #expect(swipe.direction(translation: -50, predictedEndTranslation: -300, pageWidth: 400) == .forward)
    }

    @Test func flickingBackCancels() {
        #expect(swipe.direction(translation: -160, predictedEndTranslation: 80, pageWidth: 400) == nil)
    }

    @Test func zeroWidthNeverPages() {
        #expect(swipe.direction(translation: -160, predictedEndTranslation: -200, pageWidth: 0) == nil)
    }
}
