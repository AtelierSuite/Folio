import Foundation
import Testing
@testable import Planner

struct SleepStretchTests {
    private typealias Fixture = SleepFixtures

    @Test func touchingStagesMergeIntoOneStretch() {
        let samples = [
            Fixture.sample(.inBed, Fixture.time(0), Fixture.time(1), Fixture.watch),
            Fixture.sample(.core, Fixture.time(1), Fixture.time(3), Fixture.watch),
            Fixture.sample(.awake, Fixture.time(3), Fixture.time(3, 30), Fixture.watch),
            Fixture.sample(.rem, Fixture.time(3, 30), Fixture.time(4), Fixture.phone)
        ]
        let stretches = SleepMerger().sessions(from: samples).first?.stretches
        #expect(stretches == [
            SleepStretch(interval: DateInterval(start: Fixture.time(0), end: Fixture.time(4)), isAsleep: true)
        ])
    }

    @Test func gapsSplitStretches() {
        let samples = [
            Fixture.sample(.core, Fixture.time(23, night: true), Fixture.time(2), Fixture.watch),
            Fixture.sample(.inBed, Fixture.time(3), Fixture.time(4), Fixture.phone)
        ]
        let stretches = SleepMerger().sessions(from: samples).first?.stretches
        #expect(stretches == [
            SleepStretch(
                interval: DateInterval(start: Fixture.time(23, night: true), end: Fixture.time(2)),
                isAsleep: true
            ),
            SleepStretch(interval: DateInterval(start: Fixture.time(3), end: Fixture.time(4)), isAsleep: false)
        ])
    }
}
