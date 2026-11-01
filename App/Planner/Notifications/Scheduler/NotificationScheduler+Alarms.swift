import Foundation

extension NotificationScheduler {
    /// Schedules the alarms and returns the alerts AlarmKit refused, restyled as Time Sensitive notifications.
    func replanAlarms(_ planned: [PlannedNotification]) async -> (count: Int, fallbacks: [PlannedNotification]) {
        let synchronizer = AlarmSynchronizer(client: alarmClient, ledger: alarmLedger)
        let outcome = await synchronizer.synchronize(planned.map(AlarmRequest.init(alert:)))
        let failedIdentifiers = Set(outcome.failed.map(\.id))
        let fallbacks = planned
            .filter { failedIdentifiers.contains(AlarmIdentifier.make(for: $0)) }
            .map { $0.restyled(.timeSensitive) }
        return (outcome.scheduledCount, fallbacks)
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
