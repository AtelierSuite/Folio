import Foundation

extension WakeUpAlarmCenter {
    public func setEnabled(_ isEnabled: Bool) async {
        guard isSupported else { return }
        self.isEnabled = isEnabled
        settings.isEnabled = isEnabled
        if isEnabled, await alarmClient.authorization() == .notDetermined {
            _ = try? await alarmClient.requestAuthorization()
        }
        await replan()
    }

    public func setLeadMinutes(_ minutes: Int) async {
        leadMinutes = minutes
        settings.leadMinutes = minutes
        await replan()
    }

    public func setEarliestMinutes(_ minutes: Int) async {
        earliestMinutes = minutes
        settings.earliestMinutes = minutes
        await replan()
    }

    public func setLatestEventMinutes(_ minutes: Int) async {
        latestEventMinutes = minutes
        settings.latestEventMinutes = minutes
        await replan()
    }
}
