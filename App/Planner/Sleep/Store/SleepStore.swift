import Foundation
import Observation

@MainActor
@Observable
public final class SleepStore {
    public private(set) var isShownOnTimeline: Bool
    public private(set) var preferredSourceIdentifier: String?
    public private(set) var revision = 0

    @ObservationIgnored private let source: (any SleepDataSource)?
    @ObservationIgnored private let preferences: SleepPreferences
    @ObservationIgnored private let now: @Sendable () -> Date
    @ObservationIgnored private var cachedSamples: [DateInterval: [SleepSample]] = [:]
    @ObservationIgnored private var isObserving = false
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
        if isShown {
            startObservingChanges()
        }
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
        guard isActive, !isObserving, let source else { return }
        isObserving = true
        source.startObservingChanges { [weak self] in
            await self?.refreshLastNight()
        }
    }

    public func invalidate() {
        cachedSamples.removeAll()
        revision += 1
    }

    func refreshLastNight() async {
        invalidate()
        _ = await lastNight()
    }

    private func samples(in interval: DateInterval) async -> [SleepSample] {
        guard isActive, let source else { return [] }
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
