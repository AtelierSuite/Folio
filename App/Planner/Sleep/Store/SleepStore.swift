import Foundation
import Observation

@MainActor
@Observable
public final class SleepStore {
    public private(set) var isShownOnTimeline: Bool
    public private(set) var informsFlexTime: Bool
    public private(set) var preferredSourceIdentifier: String?
    public private(set) var revision = 0

    @ObservationIgnored private let source: (any SleepDataSource)?
    @ObservationIgnored private let preferences: SleepPreferences
    @ObservationIgnored private let now: @Sendable () -> Date
    @ObservationIgnored private var cachedSamples: [DateInterval: [SleepSample]] = [:]
    @ObservationIgnored private(set) var isObserving = false
    @ObservationIgnored private let observedChanges = CoalescedRefresh()
    private static let cacheLimit = 12

    public init(
        source: (any SleepDataSource)?,
        capabilities: PlatformCapabilities,
        preferences: SleepPreferences = SleepPreferences(),
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.source = capabilities.supports(.sleep) ? source : nil
        self.preferences = preferences
        self.now = now
        isShownOnTimeline = preferences.showsOnTimeline
        informsFlexTime = preferences.informsFlexTime
        preferredSourceIdentifier = preferences.preferredSourceIdentifier
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
        updateObservation()
        invalidate()
    }

    public var isRead: Bool {
        isAvailable && (isShownOnTimeline || informsFlexTime)
    }

    public func setInformsFlexTime(_ informsFlexTime: Bool) {
        guard isAvailable else { return }
        preferences.informsFlexTime = informsFlexTime
        self.informsFlexTime = informsFlexTime
        updateObservation()
        invalidate()
    }

    public func setPreferredSourceIdentifier(_ identifier: String?) {
        preferences.preferredSourceIdentifier = identifier
        preferredSourceIdentifier = identifier
        revision += 1
    }

    public func sessions(in span: DateInterval) async -> [SleepSession] {
        let merger = SleepMerger(ranking: SleepSourceRanking(preferredSourceIdentifier: preferredSourceIdentifier))
        return merger.sessions(from: await samples(in: SleepWindow.fetchInterval(covering: span)))
            .filter { $0.interval.intersects(span) }
    }

    public func lastNight(calendar: Calendar = .current) async -> SleepSession? {
        await sessions(in: SleepWindow.lastNight(now: now(), calendar: calendar)).last
    }

    public func recentSources(days: Int = 30) async -> [SleepSource] {
        let end = now()
        let interval = DateInterval(start: end.addingTimeInterval(-Double(days) * 86400), end: end)
        return SleepSourceRanking().ranked(await samples(in: interval).map(\.source))
    }

    public func startObservingChanges() {
        guard isRead, !isObserving, let source else { return }
        isObserving = true
        source.startObservingChanges { [weak self] in
            await self?.handleObservedChange()
        }
    }

    public func stopObservingChanges() {
        guard isObserving, let source else { return }
        isObserving = false
        source.stopObservingChanges()
    }

    public func invalidate() {
        cachedSamples.removeAll()
        revision += 1
    }

    func handleObservedChange() async {
        await observedChanges.run { [weak self] in
            await self?.reloadCachedSamples()
        }
    }

    private func updateObservation() {
        if isRead {
            startObservingChanges()
        } else {
            stopObservingChanges()
        }
    }

    /// Re-reads what's been read so far, and only bumps `revision` when it changed, so a Health sync
    /// writing many samples doesn't reload the timeline for each one. A failed read, such as while
    /// the device is locked, keeps what's cached.
    private func reloadCachedSamples() async {
        guard isRead, let source else { return }
        var intervals = Set(cachedSamples.keys)
        intervals.insert(SleepWindow.fetchInterval(covering: SleepWindow.lastNight(now: now(), calendar: .current)))
        var hasChanged = false
        for interval in intervals {
            guard let samples = try? await source.samples(in: interval) else { continue }
            if let cached = cachedSamples[interval], cached != samples {
                hasChanged = true
            }
            cachedSamples[interval] = samples
        }
        if hasChanged {
            revision += 1
        }
    }

    private func samples(in interval: DateInterval) async -> [SleepSample] {
        guard isRead, let source else { return [] }
        if let cached = cachedSamples[interval] {
            return cached
        }
        guard let samples = try? await source.samples(in: interval) else { return [] }
        if cachedSamples.count >= Self.cacheLimit {
            cachedSamples.removeAll()
        }
        cachedSamples[interval] = samples
        return samples
    }
}
