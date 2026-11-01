import Foundation

/// Picks the upcoming events worth a travel time estimate and keeps estimates that make sense to show.
public struct TravelTimePlanner: Sendable {
    public var lookAhead: TimeInterval
    public var nearbyDistance: Double
    public var longestTravelTime: TimeInterval
    public var maximumEventCount: Int

    public init(
        lookAhead: TimeInterval = 24 * 3600,
        nearbyDistance: Double = 200,
        longestTravelTime: TimeInterval = 4 * 3600,
        maximumEventCount: Int = 12
    ) {
        self.lookAhead = lookAhead
        self.nearbyDistance = nearbyDistance
        self.longestTravelTime = longestTravelTime
        self.maximumEventCount = maximumEventCount
    }

    public func candidates(in events: [CalendarEvent], now: Date) -> [CalendarEvent] {
        let latestStart = now.addingTimeInterval(lookAhead)
        let upcoming = events.filter { event in
            !event.isAllDay && event.startDate > now && event.startDate <= latestStart && hasPlace(event)
        }
        return Array(upcoming.sorted { $0.startDate < $1.startDate }.prefix(maximumEventCount))
    }

    public func needsTravel(from origin: PlannerCoordinate, to destination: PlannerCoordinate) -> Bool {
        origin.distance(to: destination) > nearbyDistance
    }

    public func isShowable(_ travelTime: TimeInterval) -> Bool {
        travelTime > 0 && travelTime <= longestTravelTime
    }

    private func hasPlace(_ event: CalendarEvent) -> Bool {
        event.coordinate != nil || EventCoordinateResolver.query(for: event) != nil
    }
}
