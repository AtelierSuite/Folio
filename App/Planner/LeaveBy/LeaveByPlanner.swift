import Foundation

/// Works out the route from the event the user reached to the next event that's somewhere else.
public struct LeaveByPlanner: Sendable {
    public var lookAhead: TimeInterval
    public var nearbyDistance: Double
    public var longestTravelTime: TimeInterval

    public init(
        lookAhead: TimeInterval = 12 * 3600,
        nearbyDistance: Double = 200,
        longestTravelTime: TimeInterval = 4 * 3600
    ) {
        self.lookAhead = lookAhead
        self.nearbyDistance = nearbyDistance
        self.longestTravelTime = longestTravelTime
    }

    public func interval(after now: Date) -> DateInterval {
        DateInterval(start: now, duration: lookAhead)
    }

    /// `nil` when there is nowhere to go. Throws if the route can't be worked out right now.
    public func plan(
        leaving arrival: ArrivalCandidate,
        among events: [CalendarEvent],
        at now: Date,
        resolver: EventCoordinateResolver,
        estimator: any TravelTimeEstimating,
        transport: TravelTransport
    ) async throws -> LeaveByPlan? {
        let earliestStart = max(now, arrival.event.startDate)
        let following = events
            .filter {
                !$0.isAllDay && !$0.isDeclined && !$0.isPendingInvitation
                    && $0.startDate > earliestStart && $0.startDate <= now.addingTimeInterval(lookAhead)
            }
            .sorted { $0.startDate < $1.startDate }
        for event in following {
            guard let destination = await resolver.coordinate(for: event),
                  arrival.coordinate.distance(to: destination) > nearbyDistance else { continue }
            let travelTime = try await estimator.travelTime(
                from: arrival.coordinate, to: destination, by: transport, arrivingAt: event.startDate
            )
            guard let travelTime, travelTime > 0, travelTime <= longestTravelTime else { return nil }
            return LeaveByPlan(eventKey: event.reference.storageKey, travelTime: travelTime, transport: transport)
        }
        return nil
    }
}
