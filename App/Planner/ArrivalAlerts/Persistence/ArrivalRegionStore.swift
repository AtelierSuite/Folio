import Foundation

/// Keeps the monitored regions' candidates across launches, as CLMonitor relaunches Folio with nothing in memory.
public struct ArrivalRegionStore: @unchecked Sendable {
    public static let storageKey = "ArrivalAlerts.Regions"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public func save(_ regions: [ArrivalRegion]) {
        let entries = Dictionary(
            regions.map { ($0.id, $0.candidates.map(SavedArrivalCandidate.init)) },
            uniquingKeysWith: { first, _ in first }
        )
        defaults.set(try? JSONEncoder().encode(entries), forKey: Self.storageKey)
    }

    public func candidates(in identifier: String) -> [SavedArrivalCandidate] {
        guard let data = defaults.data(forKey: Self.storageKey),
              let entries = try? JSONDecoder().decode([String: [SavedArrivalCandidate]].self, from: data)
        else { return [] }
        return entries[identifier] ?? []
    }
}
