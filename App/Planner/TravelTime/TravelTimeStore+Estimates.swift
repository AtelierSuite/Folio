import Foundation

extension TravelTimeStore {
    struct CachedEstimateKey: Hashable {
        let eventID: String
        let location: String?
        let coordinate: PlannerCoordinate?
        let transport: TravelTransport
    }

    struct CachedEstimate {
        let origin: PlannerCoordinate
        let travelTime: TimeInterval?
        let date: Date
    }

    /// Travel times from the current location to the upcoming events in `events`,
    /// keyed by event ID. Recent estimates from about the same place are reused.
    public func estimates(for events: [CalendarEvent]) async -> [String: TravelEstimate] {
        let date = now()
        let candidates = planner.candidates(in: events, now: date)
        guard isEnabled, !candidates.isEmpty, let locator, locator.authorizationStatus == .granted,
              let origin = await locator.currentCoordinate() else { return [:] }
        let transport = transport
        var estimates: [String: TravelEstimate] = [:]
        for event in candidates {
            guard !Task.isCancelled else { break }
            guard let travelTime = await travelTime(to: event, from: origin, by: transport, now: date),
                  planner.isShowable(travelTime) else { continue }
            estimates[event.id] = TravelEstimate(
                eventID: event.id, eventStart: event.startDate, travelTime: travelTime, transport: transport
            )
        }
        return estimates
    }

    private func travelTime(
        to event: CalendarEvent,
        from origin: PlannerCoordinate,
        by transport: TravelTransport,
        now date: Date
    ) async -> TimeInterval? {
        let key = CachedEstimateKey(
            eventID: event.id, location: event.location, coordinate: event.coordinate, transport: transport
        )
        if let cached = cachedEstimates[key],
           date.timeIntervalSince(cached.date) < estimateLifetime,
           cached.origin.distance(to: origin) < originTolerance {
            return cached.travelTime
        }
        guard let destination = await resolver.coordinate(for: event) else { return nil }
        let travelTime: TimeInterval?
        if planner.needsTravel(from: origin, to: destination) {
            do {
                travelTime = try await estimator.travelTime(
                    from: origin, to: destination, by: transport, arrivingAt: event.startDate
                )
            } catch {
                return nil
            }
        } else {
            travelTime = nil
        }
        cachedEstimates[key] = CachedEstimate(origin: origin, travelTime: travelTime, date: date)
        return travelTime
    }
}
