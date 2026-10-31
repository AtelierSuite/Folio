import Foundation

/// Times a leave alert `notice` before the latest moment to set off, or right away when that's already passed.
public struct LeaveAlertPlanner: Sendable {
    public var lookAhead: TimeInterval
    public var notice: TimeInterval
    public var nearbyDistance: Double
    public var longestTravelTime: TimeInterval

    public init(
        lookAhead: TimeInterval = 12 * 3600,
        notice: TimeInterval = 5 * 60,
        nearbyDistance: Double = 200,
        longestTravelTime: TimeInterval = 4 * 3600
    ) {
        self.lookAhead = lookAhead
        self.notice = notice
        self.nearbyDistance = nearbyDistance
        self.longestTravelTime = longestTravelTime
    }

    public func interval(after now: Date) -> DateInterval {
        DateInterval(start: now, duration: lookAhead)
    }

    public func isEligible(_ event: CalendarEvent, now: Date) -> Bool {
        !event.isAllDay && event.startDate > now && event.startDate <= now.addingTimeInterval(lookAhead)
    }

    public func needsTravel(from origin: PlannerCoordinate, to destination: PlannerCoordinate) -> Bool {
        origin.distance(to: destination) > nearbyDistance
    }

    public func alert(
        for event: CalendarEvent,
        to destination: PlannerCoordinate,
        travelTime: TimeInterval,
        transport: TravelTransport,
        now: Date
    ) -> LeaveAlert? {
        guard isEligible(event, now: now), travelTime > 0, travelTime <= longestTravelTime else { return nil }
        let leaveDate = event.startDate.addingTimeInterval(-travelTime)
        return LeaveAlert(
            event: event,
            destination: destination,
            travelTime: travelTime,
            transport: transport,
            leaveDate: leaveDate,
            fireDate: max(now, leaveDate.addingTimeInterval(-notice))
        )
    }
}
