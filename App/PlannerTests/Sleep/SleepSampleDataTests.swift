import Foundation
import Testing
@testable import Planner

struct SleepSampleDataTests {
    @Test func nightRunsFromBedtimeToWakeAndMergesCleanly() {
        let wakeDay = Fixtures.date(2026, 10, 29)
        let samples = SleepSampleData.night(wakingOn: wakeDay, calendar: Fixtures.calendar)
        let sessions = SleepMerger().sessions(from: samples)
        #expect(sessions.count == 1)
        #expect(sessions.first?.interval.start == SleepFixtures.time(23, 10, night: true))
        #expect(sessions.first?.interval.end == SleepFixtures.time(7, 5))
        #expect(Set(samples.map(\.stage)) == Set(SleepStage.allCases).subtracting([.asleep]))
    }

    @Test func nightsNeverReachIntoTheFuture() {
        let now = SleepFixtures.time(6)
        let samples = SleepSampleData.nights(count: 3, endingBefore: now, calendar: Fixtures.calendar)
        #expect(samples.allSatisfy { $0.interval.end <= now })
        #expect(SleepMerger().sessions(from: samples).count == 2)
    }
}
