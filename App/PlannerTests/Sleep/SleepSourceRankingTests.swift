import Foundation
import Testing
@testable import Planner

struct SleepSourceRankingTests {
    private typealias Fixture = SleepFixtures

    @Test func watchThenPhoneThenOtherApps() {
        let ranked = SleepSourceRanking().ranked([Fixture.ring, Fixture.phone, Fixture.watch])
        #expect(ranked == [Fixture.watch, Fixture.phone, Fixture.ring])
    }

    @Test func preferredSourceComesFirst() {
        let ranked = SleepSourceRanking(preferredSourceIdentifier: Fixture.ring.id).ranked([Fixture.phone, Fixture.watch, Fixture.ring])
        #expect(ranked == [Fixture.ring, Fixture.watch, Fixture.phone])
    }

    @Test func unknownPreferredSourceKeepsDefaultOrder() {
        let ranked = SleepSourceRanking(preferredSourceIdentifier: "missing").ranked([Fixture.phone, Fixture.watch])
        #expect(ranked == [Fixture.watch, Fixture.phone])
    }

    @Test func sameKindIsOrderedByNameThenIdentifier() {
        let other = SleepSource(id: "com.example.another", name: "Ring", kind: .other)
        let ranked = SleepSourceRanking().ranked([Fixture.tracker, Fixture.ring, other])
        #expect(ranked == [other, Fixture.ring, Fixture.tracker])
    }

    @Test func duplicatesAreRemoved() {
        #expect(SleepSourceRanking().ranked([Fixture.watch, Fixture.watch]) == [Fixture.watch])
    }
}
