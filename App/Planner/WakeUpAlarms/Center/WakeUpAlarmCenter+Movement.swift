import Foundation

extension WakeUpAlarmCenter {
    static let movementDistance: Double = 1000
    static let movementReplanInterval: TimeInterval = 3600
    static let recentOriginLifetime: TimeInterval = 5 * 60

    var wantsLocationMonitoring: Bool {
        isEnabled && addsTravelTime && locationAuthorization == .always
    }

    func attachLocationMonitor() {
        guard let locationMonitor else { return }
        locationAuthorization = locationMonitor.authorization
        locationMonitor.onAuthorizationChange = { [weak self] in
            guard let self else { return }
            locationAuthorization = locationMonitor.authorization
            updateLocationMonitoring()
            Task { await self.replan() }
        }
        locationMonitor.onLocationChange = { [weak self] coordinate in
            guard let self else { return }
            performBackgroundWork { [weak self] in
                await self?.locationDidChange(to: coordinate)
            }
        }
        updateLocationMonitoring()
    }

    func updateLocationMonitoring() {
        locationMonitor?.setMonitoring(wantsLocationMonitoring)
    }

    /// Replans when the device has moved far from where travel was last measured, at most once an hour.
    func locationDidChange(to coordinate: PlannerCoordinate) async {
        let now = clock()
        settings.lastOrigin = coordinate
        recentOrigin = RecentOrigin(coordinate: coordinate, date: now)
        guard isEnabled, addsTravelTime else { return }
        if let plannedOrigin, plannedOrigin.distance(to: coordinate) < Self.movementDistance { return }
        if let lastMovementReplan, now.timeIntervalSince(lastMovementReplan) < Self.movementReplanInterval { return }
        lastMovementReplan = now
        await replan()
    }
}
