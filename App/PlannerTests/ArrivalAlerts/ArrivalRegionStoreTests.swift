import Foundation
import Testing
@testable import Planner

struct ArrivalRegionStoreTests {
    @Test func savedRegionsSurviveAReloadAndReplaceOlderOnes() throws {
        let defaults = try #require(UserDefaults(suiteName: "ArrivalRegionStore.\(UUID().uuidString)"))
        let meeting = ArrivalFixtures.event("Meeting", start: ArrivalFixtures.hours(1))
        let candidate = try #require(ArrivalFixtures.candidate(meeting))
        let region = ArrivalRegion(coordinate: ArrivalFixtures.office, radius: 150, candidates: [candidate])
        ArrivalRegionStore(defaults: defaults).save([region])
        #expect(ArrivalRegionStore(defaults: defaults).candidates(in: region.id) == [SavedArrivalCandidate(candidate)])
        ArrivalRegionStore(defaults: defaults).save([])
        #expect(ArrivalRegionStore(defaults: defaults).candidates(in: region.id).isEmpty)
    }
}
