import Foundation
import os

extension ArrivalAlertCenter {
    public func setLeaveByEnabled(_ isEnabled: Bool) async {
        guard isSupported else { return }
        isLeaveByEnabled = isEnabled
        leaveBySettings.isEnabled = isEnabled
        if isEnabled {
            regionMonitor?.requestAuthorization()
        } else {
            leaveBySettings.plan = nil
        }
        await replan()
        onLeaveByChange?()
    }

    /// Runs once per event reached, so walking in and out of the area doesn't look up the route again.
    func updateLeaveBy(arrivingAt candidates: [ArrivalCandidate], at now: Date) async {
        let nearest = candidates.min { first, second in
            abs(first.event.startDate.timeIntervalSince(now)) < abs(second.event.startDate.timeIntervalSince(now))
        }
        guard let arrival = nearest, !leaveBySettings.hasHandledArrival(at: arrival.event) else { return }
        let hiddenCalendars = visibilityStorage.hiddenCalendarIdentifiers
        let hiddenInvitations = visibilityStorage.hiddenInvitationIdentifiers
        let events = await source.events(in: leaveByPlanner.interval(after: now)).filter {
            !hiddenCalendars.contains($0.calendarIdentifier) && !$0.isHiddenInvitation(among: hiddenInvitations)
        }
        do {
            leaveBySettings.plan = try await leaveByPlanner.plan(
                leaving: arrival,
                among: events,
                at: now,
                resolver: resolver,
                estimator: estimator,
                transport: leaveAlertSettings.transport
            )
            leaveBySettings.recordArrival(at: arrival.event, on: now)
            onLeaveByChange?()
        } catch {
            arrivalLog.error("Couldn't work out when to leave: \(error.localizedDescription)")
        }
    }
}
