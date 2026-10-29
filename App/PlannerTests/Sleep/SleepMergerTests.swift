import Foundation
import Testing
@testable import Planner

struct SleepMergerTests {
    private typealias Fixture = SleepFixtures

    private func merged(_ samples: [SleepSample], preferring preferred: String? = nil) -> [SegmentSummary] {
        let merger = SleepMerger(ranking: SleepSourceRanking(preferredSourceIdentifier: preferred))
        return merger.segments(from: samples).map(SegmentSummary.init)
    }

    @Test func singleSourceStagesPassThroughInOrder() {
        let samples = [
            Fixture.sample(.deep, Fixture.time(0), Fixture.time(1), Fixture.watch),
            Fixture.sample(.core, Fixture.time(23, night: true), Fixture.time(0), Fixture.watch),
            Fixture.sample(.rem, Fixture.time(1), Fixture.time(2), Fixture.watch)
        ]
        #expect(merged(samples) == [
            SegmentSummary(.core, Fixture.time(23, night: true), Fixture.time(0), Fixture.watch),
            SegmentSummary(.deep, Fixture.time(0), Fixture.time(1), Fixture.watch),
            SegmentSummary(.rem, Fixture.time(1), Fixture.time(2), Fixture.watch)
        ])
    }

    @Test func stagesWinOverTimeInBedFromTheSameSource() {
        let samples = [
            Fixture.sample(.inBed, Fixture.time(22, night: true), Fixture.time(7), Fixture.watch),
            Fixture.sample(.core, Fixture.time(23, night: true), Fixture.time(6), Fixture.watch)
        ]
        #expect(merged(samples) == [
            SegmentSummary(.inBed, Fixture.time(22, night: true), Fixture.time(23, night: true), Fixture.watch),
            SegmentSummary(.core, Fixture.time(23, night: true), Fixture.time(6), Fixture.watch),
            SegmentSummary(.inBed, Fixture.time(6), Fixture.time(7), Fixture.watch)
        ])
    }

    @Test func watchStagesWinOverPhoneTimeInBed() {
        let samples = [
            Fixture.sample(.inBed, Fixture.time(22, night: true), Fixture.time(7), Fixture.phone),
            Fixture.sample(.core, Fixture.time(23, night: true), Fixture.time(3), Fixture.watch),
            Fixture.sample(.deep, Fixture.time(3), Fixture.time(6), Fixture.watch)
        ]
        #expect(merged(samples) == [
            SegmentSummary(.inBed, Fixture.time(22, night: true), Fixture.time(23, night: true), Fixture.phone),
            SegmentSummary(.core, Fixture.time(23, night: true), Fixture.time(3), Fixture.watch),
            SegmentSummary(.deep, Fixture.time(3), Fixture.time(6), Fixture.watch),
            SegmentSummary(.inBed, Fixture.time(6), Fixture.time(7), Fixture.phone)
        ])
    }

    @Test func watchWinsOverlappingStagesFromOtherApps() {
        let samples = [
            Fixture.sample(.deep, Fixture.time(0), Fixture.time(4), Fixture.ring),
            Fixture.sample(.core, Fixture.time(1), Fixture.time(3), Fixture.watch)
        ]
        #expect(merged(samples) == [
            SegmentSummary(.deep, Fixture.time(0), Fixture.time(1), Fixture.ring),
            SegmentSummary(.core, Fixture.time(1), Fixture.time(3), Fixture.watch),
            SegmentSummary(.deep, Fixture.time(3), Fixture.time(4), Fixture.ring)
        ])
    }

    @Test func phoneWinsOverOtherAppsWithoutAWatch() {
        let samples = [
            Fixture.sample(.asleep, Fixture.time(0), Fixture.time(4), Fixture.ring),
            Fixture.sample(.asleep, Fixture.time(2), Fixture.time(6), Fixture.phone)
        ]
        #expect(merged(samples) == [
            SegmentSummary(.asleep, Fixture.time(0), Fixture.time(2), Fixture.ring),
            SegmentSummary(.asleep, Fixture.time(2), Fixture.time(6), Fixture.phone)
        ])
    }

    @Test func preferredSourceWinsOverTheWatch() {
        let samples = [
            Fixture.sample(.core, Fixture.time(0), Fixture.time(4), Fixture.watch),
            Fixture.sample(.deep, Fixture.time(1), Fixture.time(2), Fixture.ring)
        ]
        #expect(merged(samples, preferring: Fixture.ring.id) == [
            SegmentSummary(.core, Fixture.time(0), Fixture.time(1), Fixture.watch),
            SegmentSummary(.deep, Fixture.time(1), Fixture.time(2), Fixture.ring),
            SegmentSummary(.core, Fixture.time(2), Fixture.time(4), Fixture.watch)
        ])
    }

    @Test func preferredTimeInBedStillLosesToStages() {
        let samples = [
            Fixture.sample(.inBed, Fixture.time(0), Fixture.time(4), Fixture.ring),
            Fixture.sample(.core, Fixture.time(1), Fixture.time(2), Fixture.watch)
        ]
        #expect(merged(samples, preferring: Fixture.ring.id) == [
            SegmentSummary(.inBed, Fixture.time(0), Fixture.time(1), Fixture.ring),
            SegmentSummary(.core, Fixture.time(1), Fixture.time(2), Fixture.watch),
            SegmentSummary(.inBed, Fixture.time(2), Fixture.time(4), Fixture.ring)
        ])
    }

    @Test func fullyCoveredLowerPrioritySamplesDisappear() {
        let samples = [
            Fixture.sample(.core, Fixture.time(0), Fixture.time(6), Fixture.watch),
            Fixture.sample(.asleep, Fixture.time(1), Fixture.time(5), Fixture.phone),
            Fixture.sample(.deep, Fixture.time(2), Fixture.time(3), Fixture.ring)
        ]
        #expect(merged(samples) == [SegmentSummary(.core, Fixture.time(0), Fixture.time(6), Fixture.watch)])
    }

    @Test func awakeFromTheWatchInterruptsLowerPrioritySleep() {
        let samples = [
            Fixture.sample(.asleep, Fixture.time(0), Fixture.time(4), Fixture.phone),
            Fixture.sample(.awake, Fixture.time(2), Fixture.time(2, 30), Fixture.watch)
        ]
        #expect(merged(samples) == [
            SegmentSummary(.asleep, Fixture.time(0), Fixture.time(2), Fixture.phone),
            SegmentSummary(.awake, Fixture.time(2), Fixture.time(2, 30), Fixture.watch),
            SegmentSummary(.asleep, Fixture.time(2, 30), Fixture.time(4), Fixture.phone)
        ])
    }

    @Test func adjacentSamplesWithTheSameStageAndSourceAreJoined() {
        let samples = [
            Fixture.sample(.core, Fixture.time(0), Fixture.time(1), Fixture.watch),
            Fixture.sample(.core, Fixture.time(1), Fixture.time(2), Fixture.watch),
            Fixture.sample(.core, Fixture.time(2), Fixture.time(3), Fixture.phone)
        ]
        #expect(merged(samples) == [
            SegmentSummary(.core, Fixture.time(0), Fixture.time(2), Fixture.watch),
            SegmentSummary(.core, Fixture.time(2), Fixture.time(3), Fixture.phone)
        ])
    }

    @Test func zeroLengthSamplesAreIgnored() {
        let samples = [Fixture.sample(.core, Fixture.time(1), Fixture.time(1), Fixture.watch)]
        #expect(merged(samples).isEmpty)
    }

    @Test func overlappingSamplesFromOneSourceKeepTheEarlierOne() {
        let samples = [
            Fixture.sample(.rem, Fixture.time(1), Fixture.time(3), Fixture.watch),
            Fixture.sample(.core, Fixture.time(0), Fixture.time(2), Fixture.watch)
        ]
        #expect(merged(samples) == [
            SegmentSummary(.core, Fixture.time(0), Fixture.time(2), Fixture.watch),
            SegmentSummary(.rem, Fixture.time(2), Fixture.time(3), Fixture.watch)
        ])
    }

    @Test func mergingIgnoresInputOrder() {
        let samples = [
            Fixture.sample(.inBed, Fixture.time(22, night: true), Fixture.time(7), Fixture.phone),
            Fixture.sample(.deep, Fixture.time(0), Fixture.time(4), Fixture.ring),
            Fixture.sample(.core, Fixture.time(1), Fixture.time(3), Fixture.watch),
            Fixture.sample(.awake, Fixture.time(5), Fixture.time(5, 10), Fixture.tracker)
        ]
        #expect(merged(samples) == merged(samples.reversed()))
    }
}
