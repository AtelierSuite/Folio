import Foundation
import Testing
@testable import Planner

struct SleepSessionTests {
    private typealias Fixture = SleepFixtures

    @Test func shortGapsStayInOneSession() {
        let samples = [
            Fixture.sample(.core, Fixture.time(23, night: true), Fixture.time(2), Fixture.watch),
            Fixture.sample(.core, Fixture.time(3), Fixture.time(7), Fixture.watch)
        ]
        let sessions = SleepMerger().sessions(from: samples)
        #expect(sessions.count == 1)
        #expect(sessions.first?.interval == DateInterval(start: Fixture.time(23, night: true), end: Fixture.time(7)))
    }

    @Test func longGapsStartANewSession() {
        let samples = [
            Fixture.sample(.core, Fixture.time(0), Fixture.time(7), Fixture.watch),
            Fixture.sample(.asleep, Fixture.time(14), Fixture.time(14, 30), Fixture.phone)
        ]
        let sessions = SleepMerger().sessions(from: samples)
        #expect(sessions.map(\.interval.start) == [Fixture.time(0), Fixture.time(14)])
    }

    @Test func gapIsMeasuredFromTheLatestEnd() {
        let samples = [
            Fixture.sample(.inBed, Fixture.time(0), Fixture.time(8), Fixture.phone),
            Fixture.sample(.core, Fixture.time(1), Fixture.time(2), Fixture.watch),
            Fixture.sample(.core, Fixture.time(9), Fixture.time(10), Fixture.watch)
        ]
        #expect(SleepMerger().sessions(from: samples).count == 1)
    }

    @Test func asleepDurationLeavesOutAwakeAndInBed() {
        let samples = [
            Fixture.sample(.inBed, Fixture.time(0), Fixture.time(1), Fixture.watch),
            Fixture.sample(.core, Fixture.time(1), Fixture.time(3), Fixture.watch),
            Fixture.sample(.awake, Fixture.time(3), Fixture.time(3, 30), Fixture.watch),
            Fixture.sample(.rem, Fixture.time(3, 30), Fixture.time(4), Fixture.watch)
        ]
        let session = SleepMerger().sessions(from: samples).first
        #expect(session?.asleepDuration == 2.5 * 3600)
    }

    @Test func primarySourceCoversMostTime() {
        let samples = [
            Fixture.sample(.inBed, Fixture.time(0), Fixture.time(1), Fixture.phone),
            Fixture.sample(.core, Fixture.time(1), Fixture.time(5), Fixture.watch)
        ]
        #expect(SleepMerger().sessions(from: samples).first?.primarySource == Fixture.watch)
    }

    @Test func noSamplesMeansNoSessions() {
        #expect(SleepMerger().sessions(from: []).isEmpty)
    }

    @Test func lastNightReachesBackToNoonYesterday() {
        let now = Fixture.time(9)
        let window = SleepWindow.lastNight(now: now, calendar: Fixtures.calendar)
        #expect(window == DateInterval(start: Fixture.time(12, night: true), end: now))
    }

    @Test func fetchIntervalWidensBothEdges() {
        let span = DateInterval(start: Fixture.time(0), end: Fixture.time(12))
        let widened = SleepWindow.fetchInterval(covering: span, margin: 3600)
        #expect(widened == DateInterval(start: Fixture.time(23, night: true), end: Fixture.time(13)))
    }
}
