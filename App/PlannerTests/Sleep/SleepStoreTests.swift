import Foundation
import Testing
@testable import Planner

@MainActor
struct SleepStoreTests {
    private typealias Fixture = SleepFixtures
    private let iPhone = PlatformCapabilities(platform: .iPhone, areLiveActivitiesSupported: true)
    private let iPad = PlatformCapabilities(platform: .iPad, areLiveActivitiesSupported: true)
    private let mac = PlatformCapabilities(platform: .mac, areLiveActivitiesSupported: false)
    private let night = DateInterval(start: Fixture.time(0), end: Fixture.time(12))

    private func makeStore(
        source: FakeSleepDataSource,
        capabilities: PlatformCapabilities? = nil,
        isShown: Bool = true
    ) -> SleepStore {
        let preferences = SleepPreferences(suiteName: "SleepStoreTests.\(UUID().uuidString)")
        preferences.showsOnTimeline = isShown
        return SleepStore(
            source: source,
            capabilities: capabilities ?? iPhone,
            preferences: preferences,
            now: { SleepFixtures.time(9) }
        )
    }

    private var lastNightSamples: [SleepSample] {
        [
            Fixture.sample(.inBed, Fixture.time(23, night: true), Fixture.time(7), Fixture.phone),
            Fixture.sample(.core, Fixture.time(23, 30, night: true), Fixture.time(6, 30), Fixture.watch)
        ]
    }

    @Test func hiddenByDefault() {
        let preferences = SleepPreferences(suiteName: "SleepStoreTests.\(UUID().uuidString)")
        let store = SleepStore(source: FakeSleepDataSource(), capabilities: iPhone, preferences: preferences)
        #expect(!store.isShownOnTimeline)
        #expect(!store.isActive)
    }

    @Test func iPadAndMacNeverReadSleep() async {
        for capabilities in [iPad, mac] {
            let source = FakeSleepDataSource(samples: lastNightSamples)
            let store = makeStore(source: source, capabilities: capabilities)
            store.setShownOnTimeline(true)
            store.startObservingChanges()
            #expect(!store.isAvailable)
            #expect(!store.isActive)
            #expect(await store.sessions(in: night).isEmpty)
            #expect(source.fetchCount == 0)
            #expect(!source.isObserving)
        }
    }

    @Test func turnedOffMeansNoReads() async {
        let source = FakeSleepDataSource(samples: lastNightSamples)
        let store = makeStore(source: source, isShown: false)
        #expect(await store.sessions(in: night).isEmpty)
        #expect(source.fetchCount == 0)
    }

    @Test func returnsMergedSessionsForTheSpan() async {
        let store = makeStore(source: FakeSleepDataSource(samples: lastNightSamples))
        let sessions = await store.sessions(in: night)
        #expect(sessions.count == 1)
        #expect(sessions.first?.segments.map(\.stage) == [.inBed, .core, .inBed])
        #expect(sessions.first?.interval.start == Fixture.time(23, night: true))
    }

    @Test func lastNightIsTheSessionEndingThisMorning() async {
        let store = makeStore(source: FakeSleepDataSource(samples: lastNightSamples))
        let session = await store.lastNight(calendar: Fixtures.calendar)
        #expect(session?.interval.end == Fixture.time(7))
    }

    @Test func repeatedReadsUseTheCache() async {
        let source = FakeSleepDataSource(samples: lastNightSamples)
        let store = makeStore(source: source)
        _ = await store.sessions(in: night)
        _ = await store.sessions(in: night)
        #expect(source.fetchCount == 1)
    }

    @Test func failedReadsAreNotCached() async {
        let source = FakeSleepDataSource(samples: lastNightSamples)
        source.failsReads = true
        let store = makeStore(source: source)
        #expect(await store.sessions(in: night).isEmpty)

        source.failsReads = false

        #expect(await store.sessions(in: night).count == 1)
        #expect(source.fetchCount == 2)
    }

    @Test func observedChangesRefreshAndBumpTheRevision() async {
        let source = FakeSleepDataSource()
        let store = makeStore(source: source)
        store.startObservingChanges()
        #expect(await store.sessions(in: night).isEmpty)
        let revision = store.revision

        source.samples = lastNightSamples
        await source.simulateChange()

        #expect(store.revision > revision)
        #expect(await store.sessions(in: night).count == 1)
    }

    @Test func turningOnStartsObserving() {
        let source = FakeSleepDataSource()
        let store = makeStore(source: source, isShown: false)
        store.setShownOnTimeline(true)
        #expect(store.isActive)
        #expect(source.isObserving)
    }

    @Test func preferredSourceChangesTheMerge() async {
        let samples = [
            Fixture.sample(.core, Fixture.time(0), Fixture.time(4), Fixture.watch),
            Fixture.sample(.deep, Fixture.time(1), Fixture.time(2), Fixture.ring)
        ]
        let store = makeStore(source: FakeSleepDataSource(samples: samples))
        #expect(await store.sessions(in: night).first?.segments.count == 1)
        store.setPreferredSourceIdentifier(Fixture.ring.id)
        #expect(await store.sessions(in: night).first?.segments.count == 3)
    }

    @Test func recentSourcesAreRanked() async {
        let samples = lastNightSamples + [Fixture.sample(.asleep, Fixture.time(1), Fixture.time(2), Fixture.ring)]
        let store = makeStore(source: FakeSleepDataSource(samples: samples))
        #expect(await store.recentSources() == [Fixture.watch, Fixture.phone, Fixture.ring])
    }

    @Test func preferencesPersist() {
        let suiteName = "SleepStoreTests.\(UUID().uuidString)"
        let store = SleepStore(
            source: FakeSleepDataSource(), capabilities: iPhone, preferences: SleepPreferences(suiteName: suiteName)
        )
        store.setShownOnTimeline(true)
        store.setPreferredSourceIdentifier(Fixture.ring.id)
        let reloaded = SleepStore(
            source: FakeSleepDataSource(), capabilities: iPhone, preferences: SleepPreferences(suiteName: suiteName)
        )
        #expect(reloaded.isShownOnTimeline)
        #expect(reloaded.preferredSourceIdentifier == Fixture.ring.id)
    }
}
