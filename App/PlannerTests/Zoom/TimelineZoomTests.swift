import CoreGraphics
import Testing
@testable import Planner

struct TimelineZoomTests {
    let zoom = TimelineZoom()

    @Test func fittingHourHeightShowsAllTwentyFourHours() {
        let fitting = zoom.fittingHourHeight(viewportHeight: 500, verticalInset: 10)
        #expect(fitting == 20)
        #expect(fitting * 24 + 20 == 500)
    }

    @Test func fitsWholeDayFollowsTheViewport() {
        #expect(zoom.hourHeight(for: .fitsWholeDay, fitting: 20) == 20)
        #expect(zoom.hourHeight(for: .fitsWholeDay, fitting: 12) == 12)
    }

    @Test func hourHeightIsClampedBetweenFitAndMaximum() {
        #expect(zoom.hourHeight(for: .hourHeight(10), fitting: 20) == 20)
        #expect(zoom.hourHeight(for: .hourHeight(500), fitting: 20) == zoom.maximumHourHeight)
        #expect(zoom.hourHeight(for: .hourHeight(60), fitting: 20) == 60)
    }

    @Test func tinyViewportStillReachesTheFit() {
        #expect(zoom.clamped(30, fitting: 300) == 300)
    }

    @Test func zoomingOutToTheFitStoresFitsWholeDay() {
        #expect(zoom.level(for: 20.2, fitting: 20) == .fitsWholeDay)
        #expect(zoom.level(for: 48, fitting: 20) == .hourHeight(48))
        #expect(zoom.level(for: 900, fitting: 20) == .hourHeight(zoom.maximumHourHeight))
    }

    @Test func stepsMultiplyByTheStepFactor() {
        #expect(zoom.zoomedIn(from: 48, fitting: 20) == 60)
        #expect(zoom.zoomedOut(from: 60, fitting: 20) == 48)
        #expect(zoom.zoomedOut(from: 22, fitting: 20) == 20)
    }

    @Test func zoomLimitsAreReported() {
        #expect(!zoom.canZoomOut(from: 20, fitting: 20))
        #expect(zoom.canZoomOut(from: 30, fitting: 20))
        #expect(!zoom.canZoomIn(from: zoom.maximumHourHeight))
        #expect(zoom.canZoomIn(from: 48))
    }

    @Test func detailStepsChangeOnlyPastTheStepFactor() {
        let step = zoom.detailStep(for: 48)
        #expect(zoom.detailStep(for: 48 * zoom.detailStepFactor * 1.01) > step)
        #expect(zoom.detailStep(for: 48 / zoom.detailStepFactor / 1.01) < step)
    }

    @Test func levelRoundTripsThroughItsStoredValue() {
        #expect(TimelineZoomLevel(storedValue: 0) == .fitsWholeDay)
        #expect(TimelineZoomLevel(storedValue: 72) == .hourHeight(72))
        #expect(TimelineZoomLevel(storedValue: TimelineZoomLevel.hourHeight(72).storedValue) == .hourHeight(72))
        #expect(TimelineZoomLevel.fitsWholeDay.storedValue == 0)
    }
}
