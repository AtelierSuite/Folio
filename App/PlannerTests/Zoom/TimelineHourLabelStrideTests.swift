import CoreGraphics
import Testing
@testable import Planner

struct TimelineHourLabelStrideTests {
    @Test func everyHourIsLabelledWhenThereIsRoom() {
        #expect(TimelineHourLabelStride.stride(hourHeight: 48, labelHeight: 14) == 1)
    }

    @Test func labelsThinOutAsHoursShrink() {
        #expect(TimelineHourLabelStride.stride(hourHeight: 10, labelHeight: 14) == 2)
        #expect(TimelineHourLabelStride.stride(hourHeight: 6, labelHeight: 14) == 3)
        #expect(TimelineHourLabelStride.stride(hourHeight: 3, labelHeight: 14) == 6)
    }

    @Test func largerTextNeedsMoreRoom() {
        #expect(TimelineHourLabelStride.stride(hourHeight: 20, labelHeight: 14) == 1)
        #expect(TimelineHourLabelStride.stride(hourHeight: 20, labelHeight: 30) == 2)
    }
}
