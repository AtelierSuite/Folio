import Foundation
import os

extension ArrivalAlertCenter {
    public func start() {
        guard arrivalObservation == nil, let regionMonitor else { return }
        let arrivals = regionMonitor.arrivals()
        arrivalObservation = Task { [weak self] in
            for await arrival in arrivals {
                guard let self else { return }
                await performBackgroundWork { await self.handle(arrival) }
            }
        }
    }

    public func stop() {
        arrivalObservation?.cancel()
        arrivalObservation = nil
    }

    func handle(_ arrival: RegionArrival) async {
        arrivalLog.info("Arrived in \(arrival.identifier)")
        let isKnownRegion = monitoredRegions.contains { $0.id == arrival.identifier }
        let savedArrivals = isKnownRegion
            ? []
            : await savedCandidates(in: arrival.identifier, arrivingAt: clock())
        if !isKnownRegion {
            await notify(savedArrivals, at: clock())
            await replan()
        }
        let now = clock()
        let arrivals = monitoredRegions.first { $0.id == arrival.identifier }?.candidates(arrivingAt: now)
            ?? savedArrivals
        await notify(arrivals, at: now)
        if isLeaveByActive {
            await updateLeaveBy(arrivingAt: arrivals, at: now)
        }
    }

    private func notify(_ arrivals: [ArrivalCandidate], at now: Date) async {
        guard isActive else { return }
        for candidate in arrivals where preferences.isEnabled(for: candidate.event.reference)
            && !log.hasNotified(candidate) {
            log.record(candidate, at: now)
            await notifier.notify(candidate, at: now)
        }
    }
}
