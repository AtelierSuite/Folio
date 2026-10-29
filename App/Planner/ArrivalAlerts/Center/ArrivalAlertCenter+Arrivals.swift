import Foundation
import os

extension ArrivalAlertCenter {
    public func start() {
        guard arrivalObservation == nil, let regionMonitor else { return }
        let arrivals = regionMonitor.arrivals()
        arrivalObservation = Task { [weak self] in
            for await arrival in arrivals {
                await self?.handle(arrival)
            }
        }
    }

    public func stop() {
        arrivalObservation?.cancel()
        arrivalObservation = nil
    }

    func handle(_ arrival: RegionArrival) async {
        arrivalLog.info("Arrived in \(arrival.identifier)")
        if !monitoredRegions.contains(where: { $0.id == arrival.identifier }) {
            await replan()
        }
        guard isActive, let region = monitoredRegions.first(where: { $0.id == arrival.identifier }) else { return }
        let now = clock()
        for candidate in region.candidates(arrivingAt: now) where !log.hasNotified(candidate) {
            log.record(candidate, at: now)
            await notifier.notify(candidate, at: now)
        }
    }
}
