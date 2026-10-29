import Foundation
import Testing
@testable import Planner

struct TimelineDragSnapTests {
    @Test func fifteenMinutesIsTheDefault() {
        #expect(TimelineDragSnap.default == .fifteenMinutes)
    }

    @Test func snapsToTheNearestFifteenMinutes() {
        let snap = TimelineDragSnap.fifteenMinutes
        #expect(snap.snapped(9.12) == 9.0)
        #expect(snap.snapped(9.13) == 9.25)
        #expect(snap.snapped(9.6) == 9.5)
        #expect(snap.snapped(23.95) == 24)
    }

    @Test func snapsToTheNearestFiveMinutes() {
        let snap = TimelineDragSnap.fiveMinutes
        #expect(abs(snap.snapped(9.1) - (9 + 5.0 / 60)) < 0.0001)
        #expect(abs(snap.snapped(9.2) - (9 + 10.0 / 60)) < 0.0001)
        #expect(snap.snapped(0.01) == 0)
    }
}
