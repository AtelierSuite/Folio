import Foundation

extension NotificationScheduler {
    func replanAlarms(_ planned: [PlannedNotification]) async -> Int {
        let owned = alarmLedger.identifiers
        let scheduled = await alarmClient.scheduledIdentifiers()
        let diff = AlarmPlanDiff(planned: planned, scheduledIdentifiers: scheduled, ownedIdentifiers: owned)
        await alarmClient.cancel(identifiers: diff.identifiersToCancel)
        var live = Set(scheduled).intersection(diff.plannedIdentifiers)
        for alarm in diff.alarmsToSchedule {
            let identifier = AlarmIdentifier.make(for: alarm)
            if (try? await alarmClient.schedule(alarm, identifier: identifier)) != nil {
                live.insert(identifier)
            }
        }
        alarmLedger.identifiers = live
        return live.count
    }

    @discardableResult
    public func requestAlarmAuthorization() async -> NotificationAuthorization {
        let current = await alarmClient.authorization()
        if current == .notDetermined {
            _ = try? await alarmClient.requestAuthorization()
        }
        alarmAuthorization = await alarmClient.authorization()
        await replan()
        return alarmAuthorization
    }
}
