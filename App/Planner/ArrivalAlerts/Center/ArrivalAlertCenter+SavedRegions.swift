import Foundation

extension ArrivalAlertCenter {
    /// Rebuilds the candidates saved for a region from a narrow event fetch, without geocoding or routing.
    func savedCandidates(in identifier: String, arrivingAt now: Date) async -> [ArrivalCandidate] {
        let saved = regionStore.candidates(in: identifier).filter { $0.window.contains(now) }
        guard let start = saved.map(\.window.start).min(),
              let end = saved.map(\.window.end).max() else { return [] }
        let events = await source.flexTimeEvents(in: DateInterval(start: start, end: end))
        let eventsByKey = Dictionary(
            events.map { ($0.reference.storageKey, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        return saved.compactMap { candidate in
            eventsByKey[candidate.reference.storageKey].map {
                ArrivalCandidate(event: $0, coordinate: candidate.coordinate, window: candidate.window)
            }
        }
    }
}
