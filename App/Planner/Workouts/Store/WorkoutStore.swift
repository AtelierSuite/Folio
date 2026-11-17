import Foundation
import Observation

@MainActor
@Observable
public final class WorkoutStore {
    public private(set) var isShownOnTimeline: Bool
    public private(set) var revision = 0

    @ObservationIgnored private let source: (any WorkoutDataSource)?
    @ObservationIgnored private let preferences: WorkoutPreferences
    @ObservationIgnored private let now: @Sendable () -> Date
    @ObservationIgnored private var cachedWorkouts: [DateInterval: [Workout]] = [:]
    @ObservationIgnored private var isObserving = false
    private static let cacheLimit = 12

    public init(
        source: (any WorkoutDataSource)?,
        capabilities: PlatformCapabilities,
        preferences: WorkoutPreferences = WorkoutPreferences(),
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.source = capabilities.supports(.workouts) ? source : nil
        self.preferences = preferences
        self.now = now
        isShownOnTimeline = preferences.showsOnTimeline
    }

    public var isAvailable: Bool {
        source != nil
    }

    public var isActive: Bool {
        isAvailable && isShownOnTimeline
    }

    public func setShownOnTimeline(_ isShown: Bool) {
        guard isAvailable else { return }
        preferences.showsOnTimeline = isShown
        isShownOnTimeline = isShown
        if isShown {
            startObservingChanges()
        }
        invalidate()
    }

    /// Workouts have their own Health permission, separate from sleep, so it is asked for here.
    public func requestAccessIfNeeded() async {
        guard let source, await source.authorizationRequestStatus() == .shouldRequest else { return }
        try? await source.requestAuthorization()
        invalidate()
    }

    public func workouts(in span: DateInterval) async -> [Workout] {
        await fetchedWorkouts(in: span)
            .filter { $0.interval.intersects(span) }
            .sorted { $0.interval.start < $1.interval.start }
    }

    public func recentWorkouts(days: Int = 30) async -> [Workout] {
        let end = now()
        return await workouts(in: DateInterval(start: end.addingTimeInterval(-Double(days) * 86400), end: end))
    }

    public func startObservingChanges() {
        guard isActive, !isObserving, let source else { return }
        isObserving = true
        source.startObservingChanges { [weak self] in
            await self?.invalidate()
        }
    }

    public func invalidate() {
        cachedWorkouts.removeAll()
        revision += 1
    }

    private func fetchedWorkouts(in interval: DateInterval) async -> [Workout] {
        guard isActive, let source else { return [] }
        if let cached = cachedWorkouts[interval] {
            return cached
        }
        guard let workouts = try? await source.workouts(in: interval) else { return [] }
        if cachedWorkouts.count >= Self.cacheLimit {
            cachedWorkouts.removeAll()
        }
        cachedWorkouts[interval] = workouts
        return workouts
    }
}
