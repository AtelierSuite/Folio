import Foundation
import Testing
@testable import Planner

struct EnergyCurveTests {
    private let rested = EnergyCurve(EnergyInputs(wakeHour: 7, sleepHours: 7.5, sleepDebtHours: 3))

    @Test func peaksLateMorningAndLateAfternoon() {
        let peaks = rested.markers.filter { $0.kind == .peak }.map(\.hour)
        #expect(peaks.count == 2)
        #expect((10...13).contains(peaks[0]))
        #expect((15...19).contains(peaks[1]))
    }

    @Test func dipFallsBetweenThePeaks() throws {
        let peaks = rested.markers.filter { $0.kind == .peak }.map(\.hour)
        let dip = try #require(rested.markers.first { $0.kind == .dip })
        #expect(dip.hour > peaks[0] && dip.hour < peaks[1])
        #expect(rested.peakStrength(atHour: dip.hour) < rested.peakStrength(atHour: peaks[0]))
    }

    @Test func nothingBeforeWaking() {
        #expect(rested.peakStrength(atHour: 5) == 0)
        #expect(rested.lowStrength(atHour: 5) == 0)
    }

    @Test func laterBodyClockMovesThePeaksLater() {
        let late = EnergyCurve(EnergyInputs(wakeHour: 7, sleepHours: 7.5, sleepDebtHours: 3, bodyClockLowHour: 6))
        let restedPeak = rested.markers.last { $0.kind == .peak }?.hour ?? 0
        let latePeak = late.markers.last { $0.kind == .peak }?.hour ?? 0
        #expect(latePeak > restedPeak)
    }

    @Test func windsDownInTheEvening() {
        #expect(rested.lowStrength(atHour: 23) > 0.5)
        #expect(rested.markers.last?.kind == .windDown)
    }
}
