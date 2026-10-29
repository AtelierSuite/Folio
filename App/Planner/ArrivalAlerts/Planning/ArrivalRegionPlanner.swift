import Foundation

/// Picks the regions to monitor: soonest window first, then nearest, capped at the system's region limit.
public struct ArrivalRegionPlanner: Sendable {
    public static let regionLimit = 20

    public var limit: Int
    public var radius: Double
    public var window: ArrivalWindow

    public init(limit: Int = regionLimit, radius: Double = 150, window: ArrivalWindow = ArrivalWindow()) {
        self.limit = min(limit, Self.regionLimit)
        self.radius = radius
        self.window = window
    }

    public func candidate(for event: CalendarEvent, at coordinate: PlannerCoordinate) -> ArrivalCandidate? {
        window.interval(for: event).map { ArrivalCandidate(event: event, coordinate: coordinate, window: $0) }
    }

    public func regions(
        for candidates: [ArrivalCandidate],
        now: Date,
        currentCoordinate: PlannerCoordinate? = nil
    ) -> [ArrivalRegion] {
        let upcoming = candidates.filter { $0.window.end > now }
        let grouped = Dictionary(grouping: upcoming) { ArrivalRegion.identifier(for: $0.coordinate) }
        let regions = grouped.values.compactMap { group -> ArrivalRegion? in
            let sorted = group.sorted { $0.window.start < $1.window.start }
            guard let first = sorted.first else { return nil }
            return ArrivalRegion(coordinate: first.coordinate, radius: radius, candidates: sorted)
        }
        let ranked = regions.map { region in
            RankedRegion(
                region: region,
                opensAt: max(now, region.candidates.first?.window.start ?? now),
                distance: currentCoordinate.map(region.coordinate.distance(to:)) ?? 0
            )
        }
        return ranked.sorted().prefix(limit).map(\.region)
    }
}

private struct RankedRegion: Comparable {
    let region: ArrivalRegion
    let opensAt: Date
    let distance: Double

    static func < (lhs: RankedRegion, rhs: RankedRegion) -> Bool {
        (lhs.opensAt, lhs.distance, lhs.region.id) < (rhs.opensAt, rhs.distance, rhs.region.id)
    }

    static func == (lhs: RankedRegion, rhs: RankedRegion) -> Bool {
        lhs.region.id == rhs.region.id
    }
}
