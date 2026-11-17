import Foundation
import Testing
@testable import Planner

@MainActor
struct WorkoutStoreTests {
    private let iPhone = PlatformCapabilities(platform: .iPhone, areLiveActivitiesSupported: true)
    private let iPad = PlatformCapabilities(platform: .iPad, areLiveActivitiesSupported: true)
    private let mac = PlatformCapabilities(platform: .mac, areLiveActivitiesSupported: false)
    private let reference = Date(timeIntervalSince1970: 1_800_000_000)

    private var day: DateInterval {
        DateInterval(start: reference.addingTimeInterval(-12 * 3600), end: reference.addingTimeInterval(12 * 3600))
    }

    private var morningRun: Workout {
        Workout(
            id: UUID(uuidString: "6F2C1E44-0A5B-4D8E-9C3F-2B7A1D4E5F60") ?? UUID(),
            activity: .running,
            interval: DateInterval(start: reference.addingTimeInterval(-3600), duration: 1800)
        )
    }

    private func makeStore(
        source: FakeWorkoutDataSource,
        capabilities: PlatformCapabilities? = nil,
        isShown: Bool = true
    ) -> WorkoutStore {
        let preferences = WorkoutPreferences(suiteName: "WorkoutStoreTests.\(UUID().uuidString)")
        preferences.showsOnTimeline = isShown
        let now = reference
        return WorkoutStore(
            source: source, capabilities: capabilities ?? iPhone, preferences: preferences, now: { now }
        )
    }

    @Test func hiddenByDefault() {
        let preferences = WorkoutPreferences(suiteName: "WorkoutStoreTests.\(UUID().uuidString)")
        let store = WorkoutStore(source: FakeWorkoutDataSource(), capabilities: iPhone, preferences: preferences)
        #expect(!store.isShownOnTimeline)
        #expect(!store.isActive)
    }

    @Test func iPadAndMacNeverReadWorkouts() async {
        for capabilities in [iPad, mac] {
            let source = FakeWorkoutDataSource(workouts: [morningRun])
            let store = makeStore(source: source, capabilities: capabilities)
            store.setShownOnTimeline(true)
            await store.requestAccessIfNeeded()
            #expect(!store.isAvailable)
            #expect(await store.workouts(in: day).isEmpty)
            #expect(source.fetchCount == 0)
            #expect(source.requestCount == 0)
            #expect(!source.isObserving)
        }
    }

    @Test func turnedOffMeansNoReads() async {
        let source = FakeWorkoutDataSource(workouts: [morningRun])
        let store = makeStore(source: source, isShown: false)
        #expect(await store.workouts(in: day).isEmpty)
        #expect(source.fetchCount == 0)
    }

    @Test func readsWorkoutsInSpanAndCachesThem() async {
        let source = FakeWorkoutDataSource(workouts: [morningRun])
        let store = makeStore(source: source)
        #expect(await store.workouts(in: day) == [morningRun])
        #expect(await store.workouts(in: day) == [morningRun])
        #expect(source.fetchCount == 1)
    }

    @Test func recentWorkoutsEndAtNow() async {
        let source = FakeWorkoutDataSource(workouts: [morningRun])
        let store = makeStore(source: source)
        #expect(await store.recentWorkouts() == [morningRun])
    }

    @Test func requestsAccessOnlyOnce() async {
        let source = FakeWorkoutDataSource()
        let store = makeStore(source: source)
        await store.requestAccessIfNeeded()
        await store.requestAccessIfNeeded()
        #expect(source.requestCount == 1)
    }

    @Test func turningOnStartsObservingAndChangesRefetch() async {
        let source = FakeWorkoutDataSource()
        let store = makeStore(source: source, isShown: false)
        store.setShownOnTimeline(true)
        #expect(source.isObserving)
        #expect(await store.workouts(in: day).isEmpty)
        source.workouts = [morningRun]
        let revision = store.revision
        await source.simulateChange()
        #expect(store.revision > revision)
        #expect(await store.workouts(in: day) == [morningRun])
    }

    @Test func sampleDataNeverEndsInTheFuture() {
        let workouts = WorkoutSampleData.workouts(days: 14, endingBefore: reference, calendar: .current)
        #expect(!workouts.isEmpty)
        #expect(workouts.allSatisfy { $0.interval.end <= reference })
    }
}
