import Foundation

/// Picks the upcoming events worth a travel time estimate and keeps estimates that make sense to show.
public struct TravelTimePlanner: Sendable {
    public var lookAhead: TimeInterval
    public var nearbyDistance: Double
    public var longestTravelTime: TimeInterval
    public var maximumEventCount: Int
    public var calendar: Calendar

    public init(
        lookAhead: TimeInterval = 24 * 3600,
        nearbyDistance: Double = 200,
        longestTravelTime: TimeInterval = 4 * 3600,
        maximumEventCount: Int = 12,
        calendar: Calendar = .current
    ) {
        self.lookAhead = lookAhead
        self.nearbyDistance = nearbyDistance
        self.longestTravelTime = longestTravelTime
        self.maximumEventCount = maximumEventCount
        self.calendar = calendar
    }

    public func candidates(in events: [CalendarEvent], now: Date) -> [CalendarEvent] {
        let latestStart = now.addingTimeInterval(lookAhead)
        let upcoming = events.filter { event in
            !event.isAllDay && event.startDate > now && event.startDate <= latestStart && hasPlace(event)
        }
        return Array(upcoming.sorted { $0.startDate < $1.startDate }.prefix(maximumEventCount))
    }

    /// The latest timed event with a place that starts earlier on the same day, which the trip to `event` starts from.
    public func previousPlacedEvent(before event: CalendarEvent, in events: [CalendarEvent]) -> CalendarEvent? {
        events
            .filter { other in
                other.id != event.id && !other.isAllDay && other.startDate < event.startDate
                    && calendar.isDate(other.startDate, inSameDayAs: event.startDate) && hasPlace(other)
            }
            .max { $0.startDate < $1.startDate }
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
