import Foundation

extension LeaveAlertCenter {
    /// An alarm can't ring in the past, so alerts already due go out as notifications, as do any AlarmKit refuses.
    static let alarmLeadTime: TimeInterval = 60

    /// Schedules the alerts that ring as alarms and returns the ones left to send as notifications.
    func replanAlarms(for alerts: [LeaveAlert], now: Date) async -> [LeaveAlert] {
        if ringsAsAlarm {
            alarmAuthorization = await alarmClient.authorization()
        }
        let usesAlarms = ringsAsAlarm && alarmAuthorization.allowsScheduling
        let alarmAlerts = usesAlarms ? alerts.filter { $0.fireDate > now.addingTimeInterval(Self.alarmLeadTime) } : []
        guard usesAlarms || !alarmLedger.identifiers.isEmpty else { return alerts }
        let requests = alarmAlerts.map { $0.alarmRequest(formatter: formatter) }
        let outcome = await AlarmSynchronizer(client: alarmClient, ledger: alarmLedger).synchronize(requests)
        let failed = Set(outcome.failed.map(\.id))
        let ringing = Set(zip(alarmAlerts, requests).filter { !failed.contains($0.1.id) }.map(\.0.id))
        return alerts.filter { !ringing.contains($0.id) }
    }

    public func setRingsAsAlarm(_ ringsAsAlarm: Bool) async {
        self.ringsAsAlarm = ringsAsAlarm
        settings.ringsAsAlarm = ringsAsAlarm
        if ringsAsAlarm, await alarmClient.authorization() == .notDetermined {
            _ = try? await alarmClient.requestAuthorization()
        }
        await replan()
    }
}

extension LeaveAlert {
    func alarmRequest(formatter: NotificationContentFormatter) -> AlarmRequest {
        AlarmRequest(
            id: AlarmIdentifier.make(fromNotificationIdentifier: id),
            fireDate: fireDate,
            title: formatter.leaveAlarmTitle(for: self),
            tint: event.color,
            item: NotificationItem(kind: .event, reference: event.reference, fireDate: fireDate),
            secondaryAction: .open
        )
    }
}
