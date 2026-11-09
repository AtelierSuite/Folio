import Foundation

extension WakeUpAlarmCenter {
    struct TravelTimeKey: Hashable {
        let eventID: String
        let eventStart: Date
        let transport: TravelTransport
    }

    struct RecentOrigin {
        let coordinate: PlannerCoordinate
        let date: Date
    }

    struct CachedTravelTime {
        let origin: PlannerCoordinate
        let travelTime: TimeInterval?
        let date: Date
    }

    static let travelTimeLifetime: TimeInterval = 30 * 60
    static let originTolerance: Double = 500

    /// Travel times from the current location, or the last known one when it can't be read, keyed by event ID.
    func travelTimes(to events: [CalendarEvent], now: Date) async -> [String: TimeInterval] {
        guard !events.isEmpty, let origin = await travelOrigin(now: now) else { return [:] }
        plannedOrigin = origin
        var travelTimes: [String: TimeInterval] = [:]
        for event in events {
            if let travelTime = await travelTime(to: event, from: origin, now: now) {
                travelTimes[event.id] = travelTime
            }
        }
        return travelTimes
    }

    private func travelOrigin(now: Date) async -> PlannerCoordinate? {
        if let recentOrigin, now.timeIntervalSince(recentOrigin.date) < Self.recentOriginLifetime {
            return recentOrigin.coordinate
        }
        if let locator, locator.authorizationStatus == .granted, let origin = await locator.currentCoordinate() {
            settings.lastOrigin = origin
            recentOrigin = RecentOrigin(coordinate: origin, date: now)
            return origin
        }
        return settings.lastOrigin
    }

    private func travelTime(to event: CalendarEvent, from origin: PlannerCoordinate, now: Date) async -> TimeInterval? {
        let key = TravelTimeKey(eventID: event.id, eventStart: event.startDate, transport: transport)
        let cached = cachedTravelTimes[key]
        if let cached, now.timeIntervalSince(cached.date) < Self.travelTimeLifetime,
           cached.origin.distance(to: origin) < Self.originTolerance {
            return cached.travelTime
        }
        guard let destination = await resolver.coordinate(for: event) else { return cached?.travelTime }
        var travelTime: TimeInterval?
        if travelPlanner.needsTravel(from: origin, to: destination) {
            do {
                travelTime = try await estimator.travelTime(
                    from: origin, to: destination, by: transport, arrivingAt: event.startDate
                )
            } catch {
                // An older estimate beats waking up without any travel time when directions are unreachable.
                return cached?.travelTime
            }
        }
        let plausible = travelTime.flatMap { travelPlanner.isShowable($0) ? $0 : nil }
        cachedTravelTimes[key] = CachedTravelTime(origin: origin, travelTime: plausible, date: now)
        return plausible
    }
}
