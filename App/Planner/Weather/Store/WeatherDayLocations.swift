import Foundation

/// Picks where to show weather for each day: home, unless the day has an event far enough
/// away to mean the user is travelling, in which case the longest such event wins.
public struct WeatherDayLocations: Sendable {
    public var travelDistance: Double

    public init(travelDistance: Double = 100_000) {
        self.travelDistance = travelDistance
    }

    public func locations(
        for days: [DateInterval],
        home: PlannerCoordinate,
        events: [CalendarEvent]
    ) -> [Date: PlannerCoordinate] {
        let awayEvents = events.filter { event in
            guard let coordinate = event.coordinate else { return false }
            return coordinate.distance(to: home) >= travelDistance
        }
        var locations: [Date: PlannerCoordinate] = [:]
        for day in days {
            let longestAway = awayEvents
                .filter { $0.overlaps(day) }
                .max { overlap(of: $0, with: day) < overlap(of: $1, with: day) }
            locations[day.start] = longestAway?.coordinate ?? home
        }
        return locations
    }

    private func overlap(of event: CalendarEvent, with day: DateInterval) -> TimeInterval {
        max(0, min(event.endDate, day.end).timeIntervalSince(max(event.startDate, day.start)))
    }
}
