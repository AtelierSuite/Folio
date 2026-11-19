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

    /// Travel times to the upcoming events in `events`, keyed by event ID. Each trip starts at the
    /// previous timed event with a place that day, or at the current location when there is none.
    /// Recent estimates from about the same place are reused.
    public func estimates(for events: [CalendarEvent]) async -> [String: TravelEstimate] {
        let date = now()
        let candidates = planner.candidates(in: events, now: date)
        guard isEnabled, !candidates.isEmpty, let locator, locator.authorizationStatus == .granted else { return [:] }
        let transport = transport
        var hasLookedUpCurrentLocation = false
        var currentLocation: PlannerCoordinate?
        var estimates: [String: TravelEstimate] = [:]
        for event in candidates {
            guard !Task.isCancelled else { break }
            var origin = await previousEventOrigin(before: event, in: events)
            if origin == nil {
                if !hasLookedUpCurrentLocation {
                    currentLocation = await locator.currentCoordinate()
                    hasLookedUpCurrentLocation = true
                }
                origin = currentLocation
            }
            guard let origin,
                  let travelTime = await travelTime(to: event, from: origin, by: transport, now: date),
                  planner.isShowable(travelTime) else { continue }
            estimates[event.id] = TravelEstimate(
                eventID: event.id, eventStart: event.startDate, travelTime: travelTime, transport: transport
            )
        }
        return estimates
    }

    private func previousEventOrigin(
        before event: CalendarEvent,
        in events: [CalendarEvent]
    ) async -> PlannerCoordinate? {
        guard let previous = planner.previousPlacedEvent(before: event, in: events) else { return nil }
        return await resolver.coordinate(for: previous)
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
